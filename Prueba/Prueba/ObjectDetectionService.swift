import CoreML
import CoreVideo
import UIKit
import Vision

struct DetectionResult: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let confidence: Float
    let boundingBox: CGRect
}

final class ObjectDetectionService {
    private let model: VNCoreMLModel
    private let classLabels = ["Fridge", "Oven", "TV"]
    private let minimumConfidence: Float = 0.35

    init() throws {
        let configuration = MLModelConfiguration()
        let coreMLModel = try final_(configuration: configuration).model
        self.model = try VNCoreMLModel(for: coreMLModel)
    }

    func detect(in image: UIImage) async throws -> [DetectionResult] {
        guard let cgImage = image.cgImage else {
            throw DetectionError.invalidImage
        }

        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let detections = self.parseResults(request.results)
                continuation.resume(returning: detections)
            }

            request.imageCropAndScaleOption = .scaleFill

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func detect(in pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation = .right) throws -> [DetectionResult] {
        var detectedResults: [DetectionResult] = []
        var thrownError: Error?

        let request = VNCoreMLRequest(model: model) { request, error in
            if let error {
                thrownError = error
                return
            }

            detectedResults = self.parseResults(request.results)
        }

        request.imageCropAndScaleOption = .scaleFill

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation)
        try handler.perform([request])

        if let thrownError {
            throw thrownError
        }

        return detectedResults
    }

    private func parseResults(_ results: [Any]?) -> [DetectionResult] {
        // Try standard object observations first (VNRecognizedObjectObservation)
        if let observations = results as? [VNRecognizedObjectObservation], !observations.isEmpty {
            let detections = observations.compactMap { observation -> DetectionResult? in
                guard let topLabel = observation.labels.first else { return nil }
                return DetectionResult(
                    label: topLabel.identifier,
                    confidence: topLabel.confidence,
                    boundingBox: observation.boundingBox
                )
            }
            return postProcess(detections)
        }

        // Handle CoreML multi-array outputs from pipeline models
        if let coreMLResults = results as? [VNCoreMLFeatureValueObservation] {
            return parsePipelineResults(coreMLResults)
        }

        return []
    }

    private func parsePipelineResults(_ observations: [VNCoreMLFeatureValueObservation]) -> [DetectionResult] {
        var confidenceArray: MLMultiArray?
        var coordinatesArray: MLMultiArray?

        for observation in observations {
            guard let multiArray = observation.featureValue.multiArrayValue else { continue }

            let name = observation.featureName
            if name == "confidence" {
                confidenceArray = multiArray
            } else if name == "coordinates" {
                coordinatesArray = multiArray
            }
        }

        guard let confidences = confidenceArray,
              let coordinates = coordinatesArray else { return [] }

        let numDetections = confidences.shape[0].intValue
        let availableClasses = confidences.shape.count > 1 ? confidences.shape[1].intValue : classLabels.count
        let numClasses = min(classLabels.count, availableClasses)

        guard numClasses > 0 else { return [] }

        var detections: [DetectionResult] = []

        for i in 0..<numDetections {
            // Find best class for this detection
            var bestClassIndex = 0
            var bestConfidence: Float = 0

            for c in 0..<numClasses {
                let index = [NSNumber(value: i), NSNumber(value: c)]
                let conf = Float(truncating: confidences[index])
                if conf > bestConfidence {
                    bestConfidence = conf
                    bestClassIndex = c
                }
            }

            guard bestConfidence > minimumConfidence else { continue }

            // Coordinates are [centerX, centerY, width, height] normalized
            let cx = Double(truncating: coordinates[[NSNumber(value: i), NSNumber(value: 0)]])
            let cy = Double(truncating: coordinates[[NSNumber(value: i), NSNumber(value: 1)]])
            let w = Double(truncating: coordinates[[NSNumber(value: i), NSNumber(value: 2)]])
            let h = Double(truncating: coordinates[[NSNumber(value: i), NSNumber(value: 3)]])

            // Convert from center-based to Vision coordinate system (origin bottom-left)
            let x = cx - w / 2
            let y = 1.0 - (cy + h / 2)
            let boundingBox = CGRect(x: x, y: y, width: w, height: h)

            detections.append(DetectionResult(
                label: classLabels[bestClassIndex],
                confidence: bestConfidence,
                boundingBox: boundingBox
            ))
        }

        return postProcess(detections)
    }

    private func postProcess(_ detections: [DetectionResult]) -> [DetectionResult] {
        let normalizedDetections = detections.compactMap { detection -> DetectionResult? in
            guard let normalizedLabel = normalizeLabel(detection.label),
                  detection.confidence >= minimumConfidence else {
                return nil
            }

            return DetectionResult(
                label: normalizedLabel,
                confidence: detection.confidence,
                boundingBox: expandedBoundingBox(for: detection.boundingBox)
            )
        }

        return nonMaximumSuppressed(normalizedDetections)
            .sorted { $0.confidence > $1.confidence }
    }

    private func normalizeLabel(_ label: String) -> String? {
        let normalized = label.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch normalized {
        case "fridge", "refrigerator":
            return "Fridge"
        case "oven", "stove":
            return "Oven"
        case "tv", "television":
            return "TV"
        default:
            return classLabels.first { $0.lowercased() == normalized }
        }
    }

    private func expandedBoundingBox(for rect: CGRect) -> CGRect {
        let horizontalInset = rect.width * -0.08
        let verticalInset = rect.height * -0.12
        let expanded = rect.insetBy(dx: horizontalInset, dy: verticalInset)

        let clampedOriginX = max(0, expanded.origin.x)
        let clampedOriginY = max(0, expanded.origin.y)
        let maxWidth = min(1 - clampedOriginX, expanded.width)
        let maxHeight = min(1 - clampedOriginY, expanded.height)

        return CGRect(
            x: clampedOriginX,
            y: clampedOriginY,
            width: max(0, maxWidth),
            height: max(0, maxHeight)
        )
    }

    private func nonMaximumSuppressed(_ detections: [DetectionResult]) -> [DetectionResult] {
        let sortedDetections = detections.sorted { $0.confidence > $1.confidence }
        var keptDetections: [DetectionResult] = []

        for detection in sortedDetections {
            let overlapsExisting = keptDetections.contains { kept in
                kept.label == detection.label && intersectionOverUnion(kept.boundingBox, detection.boundingBox) > 0.45
            }

            if !overlapsExisting {
                keptDetections.append(detection)
            }
        }

        return keptDetections
    }

    private func intersectionOverUnion(_ lhs: CGRect, _ rhs: CGRect) -> CGFloat {
        let intersection = lhs.intersection(rhs)
        guard !intersection.isNull else { return 0 }

        let intersectionArea = intersection.width * intersection.height
        let unionArea = (lhs.width * lhs.height) + (rhs.width * rhs.height) - intersectionArea
        guard unionArea > 0 else { return 0 }
        return intersectionArea / unionArea
    }
}

enum DetectionError: LocalizedError {
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "No se pudo leer la imagen seleccionada."
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up:
            self = .up
        case .down:
            self = .down
        case .left:
            self = .left
        case .right:
            self = .right
        case .upMirrored:
            self = .upMirrored
        case .downMirrored:
            self = .downMirrored
        case .leftMirrored:
            self = .leftMirrored
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
