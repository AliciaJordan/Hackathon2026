import CoreML
import CoreVideo
import UIKit
import Vision

struct DetectionResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    let boundingBox: CGRect
}

final class ObjectDetectionService {
    private let model: VNCoreMLModel
    private let classLabels = ["Fridge", "Oven", "TV"]

    init() throws {
        let configuration = MLModelConfiguration()
        let coreMLModel = try objDetectorCDMXEnactus_720(configuration: configuration).model
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
            return observations.compactMap { observation -> DetectionResult? in
                guard let topLabel = observation.labels.first else { return nil }
                return DetectionResult(
                    label: topLabel.identifier,
                    confidence: topLabel.confidence,
                    boundingBox: observation.boundingBox
                )
            }
            .sorted { $0.confidence > $1.confidence }
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
            guard let featureValue = observation.featureValue as? MLFeatureValue,
                  let multiArray = featureValue.multiArrayValue else { continue }

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
        let numClasses = classLabels.count

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

            guard bestConfidence > 0.25 else { continue }

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

        return detections.sorted { $0.confidence > $1.confidence }
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
