import AVFoundation
import Combine
import SwiftUI

final class CameraDetectionController: NSObject, ObservableObject {
    let session = AVCaptureSession()

    @Published var authorizationDenied = false
    @Published var isRunning = false
    @Published var detections: [DetectionResult] = []
    @Published var errorMessage: String?

    private let detector: ObjectDetectionService?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private let outputQueue = DispatchQueue(label: "camera.output.queue")
    private var isConfigured = false
    private var isProcessingFrame = false

    init(detector: ObjectDetectionService?) {
        self.detector = detector
        super.init()
    }

    func start() async {
        guard detector != nil else {
            DispatchQueue.main.async {
                self.errorMessage = "No se pudo inicializar el modelo."
            }
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.authorizationDenied = false
            }
            await configureAndRunIfNeeded()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            DispatchQueue.main.async {
                self.authorizationDenied = !granted
            }
            if granted {
                await configureAndRunIfNeeded()
            }
        default:
            DispatchQueue.main.async {
                self.authorizationDenied = true
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.isRunning = false
            }
        }
    }

    private func configureAndRunIfNeeded() async {
        if !isConfigured {
            await withCheckedContinuation { continuation in
                sessionQueue.async { [weak self] in
                    self?.configureSession()
                    continuation.resume()
                }
            }
        }

        sessionQueue.async { [weak self] in
            guard let self, self.isConfigured, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async {
                self.isRunning = true
            }
        }
    }

    private func configureSession() {
        guard !isConfigured else { return }

        session.beginConfiguration()
        session.sessionPreset = .vga640x480

        defer {
            session.commitConfiguration()
        }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            DispatchQueue.main.async {
                self.errorMessage = "No se encontro una camara disponible."
            }
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            guard session.canAddInput(input) else {
                DispatchQueue.main.async {
                    self.errorMessage = "No se pudo conectar la entrada de camara."
                }
                return
            }
            session.addInput(input)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            return
        }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        ]
        output.setSampleBufferDelegate(self, queue: outputQueue)

        guard session.canAddOutput(output) else {
            DispatchQueue.main.async {
                self.errorMessage = "No se pudo conectar la salida de video."
            }
            return
        }

        session.addOutput(output)
        output.connection(with: .video)?.videoRotationAngle = 90

        isConfigured = true
    }
}

extension CameraDetectionController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isProcessingFrame else { return }
        guard let detector else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        isProcessingFrame = true
        defer { isProcessingFrame = false }

        do {
            let detections = try detector.detect(in: pixelBuffer)
            DispatchQueue.main.async {
                self.detections = detections.filter { $0.confidence >= 0.35 }
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.previewLayer.session = session
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
