import PhotosUI
import SwiftUI

struct ConsumptionView: View {
    @StateObject private var camera = CameraDetectionController(detector: try? ObjectDetectionService())
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var galleryDetections: [DetectionResult] = []
    @State private var trackedDevices: [TrackedDevice] = []
    @State private var autoCapturedLabels: Set<String> = []
    @State private var isAnalyzingGallery = false
    @State private var galleryErrorMessage: String?
    @State private var selectedMode: DetectionMode = .camera
    @State private var showingCustomDeviceSheet = false

    private let detector = try? ObjectDetectionService()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    modeSection
                    activeSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 110)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .task(id: selectedItem) {
                await loadSelectedImage()
            }
            .task {
                await camera.start()
            }
            .onChange(of: camera.detections) { _, detections in
                autoAddDevices(from: detections, source: .camera)
            }
            .onChange(of: galleryDetections) { _, detections in
                autoAddDevices(from: detections, source: .gallery)
            }
            .onDisappear {
                camera.stop()
            }
            .sheet(isPresented: $showingCustomDeviceSheet) {
                CustomDeviceSheet { label in
                    addTrackedDevice(label: label, confidence: nil, source: .manual)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Consumo")
                .font(AppTheme.display(42))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Usa tu detector en tiempo real con camara o prueba una imagen de galeria.")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: 320, alignment: .leading)
        }
    }

    private var modeSection: some View {
        HStack(spacing: 10) {
            modeButton(title: "Camara", mode: .camera)
            modeButton(title: "Galeria", mode: .gallery)
        }
    }

    @ViewBuilder
    private var activeSection: some View {
        switch selectedMode {
        case .camera:
            cameraSection
        case .gallery:
            gallerySection
        }
    }

    private var cameraSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Detector en vivo")
                    .font(AppTheme.title(28))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                if camera.isRunning {
                    Text("\(camera.detections.count) detecciones")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.primaryDark)
                }
            }

            if camera.authorizationDenied {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Permiso de camara requerido")
                        .font(AppTheme.title(18))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Activa el acceso a la camara en Settings para usar deteccion en vivo.")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(20)
                .editorialCard(fill: AppTheme.surfaceMuted)
            } else {
                LiveDetectionPreview(session: camera.session, detections: camera.detections)
            }

            if let errorMessage = camera.errorMessage {
                Text(errorMessage)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.error)
            }

            detectionList(
                camera.detections,
                emptyMessage: "Apunta la camara a un objeto para ver detecciones en vivo.",
                source: .camera
            )
            devicesSection
        }
    }

    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Detector por imagen")
                .font(AppTheme.title(28))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Selecciona una imagen para que el modelo detecte tu dispositvo")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)

            PhotosPicker(selection: $selectedItem, matching: .images) {
                HStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle")
                    Text(selectedImage == nil ? "Seleccionar imagen" : "Cambiar imagen")
                }
            }
            .buttonStyle(EditorialPrimaryButtonStyle())

            if let galleryErrorMessage {
                Text(galleryErrorMessage)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.error)
            }

            if let selectedImage {
                HStack {
                    Text("Resultados")
                        .font(AppTheme.title(24))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    if isAnalyzingGallery {
                        ProgressView()
                            .tint(AppTheme.primary)
                    } else {
                        Text("\(galleryDetections.count) detecciones")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.primaryDark)
                    }
                }

                DetectionPreview(image: selectedImage, detections: galleryDetections)
                detectionList(
                    galleryDetections,
                    emptyMessage: "No hubo detecciones visibles para esta imagen.",
                    source: .gallery
                )
            }

            devicesSection
        }
        .padding(24)
        .editorialCard(fill: AppTheme.surfaceMuted)
    }

    @ViewBuilder
    private func detectionList(_ detections: [DetectionResult], emptyMessage: String, source: DeviceSource) -> some View {
        if detections.isEmpty {
            Text(emptyMessage)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .editorialCard()
        } else {
            VStack(spacing: 0) {
                ForEach(detections) { detection in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(AppTheme.primary)
                            .frame(width: 10, height: 10)
                            .padding(.top, 5)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(detection.label)
                                .font(AppTheme.title(16))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Confianza: \(Int(detection.confidence * 100))%")
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        Button(deviceButtonTitle(for: detection.label)) {
                            addTrackedDevice(from: detection, source: source)
                        }
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.primaryDark)
                    }
                    .padding(.vertical, 14)

                    if detection.id != detections.last?.id {
                        Divider()
                            .overlay(AppTheme.border)
                    }
                }
            }
            .padding(.horizontal, 16)
            .editorialCard()
        }
    }

    private var devicesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Mis dispositivos")
                    .font(AppTheme.title(24))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Menu {
                    ForEach(["Fridge", "Oven", "TV"], id: \.self) { label in
                        Button("Agregar \(label)") {
                            addTrackedDevice(label: label, confidence: nil, source: .manual)
                        }
                    }
                    Button("Agregar otro dispositivo") {
                        showingCustomDeviceSheet = true
                    }
                } label: {
                    Label("Agregar otro", systemImage: "plus")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.primaryDark)
                }
            }

            if trackedDevices.isEmpty {
                Text("Cuando el modelo detecte `Fridge`, `Oven` o `TV`, apareceran aqui. Tambien puedes agregarlos manualmente.")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .editorialCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(trackedDevices) { device in
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(AppTheme.primaryDark)
                                .frame(width: 10, height: 10)
                                .padding(.top, 5)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(device.label)
                                    .font(AppTheme.title(16))
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text(deviceSubtitle(for: device))
                                    .font(AppTheme.bodyFont)
                                    .foregroundStyle(AppTheme.textSecondary)
                                if let estimate = deviceEstimate(for: device.label) {
                                    Text("Promedio: \(estimate.kilowattHoursPerHour) kWh/h · \(estimate.hourlyCost) MXN/h")
                                        .font(AppTheme.captionFont)
                                        .foregroundStyle(AppTheme.primaryDark)
                                }
                            }

                            Spacer()

                            Button {
                                addTrackedDevice(label: device.label, confidence: device.confidence, source: .manual)
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                            .foregroundStyle(AppTheme.primaryDark)

                            Button(role: .destructive) {
                                removeTrackedDevice(device)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .foregroundStyle(AppTheme.error)
                        }
                        .padding(.vertical, 14)

                        if device.id != trackedDevices.last?.id {
                            Divider()
                                .overlay(AppTheme.border)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .editorialCard()
            }
        }
    }

    private func modeButton(title: String, mode: DetectionMode) -> some View {
        Button {
            selectedMode = mode
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ModeButtonStyle(isSelected: selectedMode == mode))
    }

    @MainActor
    private func loadSelectedImage() async {
        guard let selectedItem else { return }

        isAnalyzingGallery = true
        galleryErrorMessage = nil
        galleryDetections = []

        do {
            guard let data = try await selectedItem.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                throw DetectionError.invalidImage
            }

            selectedImage = image

            guard let detector else {
                galleryErrorMessage = "No se pudo inicializar el modelo."
                isAnalyzingGallery = false
                return
            }

            galleryDetections = try await detector.detect(in: image)
        } catch {
            galleryErrorMessage = error.localizedDescription
        }

        isAnalyzingGallery = false
    }

    private func autoAddDevices(from detections: [DetectionResult], source: DeviceSource) {
        for detection in detections {
            if !autoCapturedLabels.contains(detection.label) {
                addTrackedDevice(from: detection, source: source)
                autoCapturedLabels.insert(detection.label)
            }
        }
    }

    private func addTrackedDevice(from detection: DetectionResult, source: DeviceSource) {
        addTrackedDevice(label: detection.label, confidence: detection.confidence, source: source)
    }

    private func addTrackedDevice(label: String, confidence: Float?, source: DeviceSource) {
        trackedDevices.append(
            TrackedDevice(
                label: label,
                confidence: confidence,
                source: source
            )
        )
    }

    private func removeTrackedDevice(_ device: TrackedDevice) {
        trackedDevices.removeAll { $0.id == device.id }
    }

    private func deviceButtonTitle(for label: String) -> String {
        trackedDevices.contains(where: { $0.label == label }) ? "Agregar otro" : "Guardar"
    }

    private func deviceSubtitle(for device: TrackedDevice) -> String {
        if let confidence = device.confidence {
            return "\(device.source.title) · \(Int(confidence * 100))% confianza"
        }
        return "\(device.source.title) · agregado manualmente"
    }

    private func deviceEstimate(for label: String) -> DeviceEstimate? {
        switch label.lowercased() {
        case "fridge":
            return DeviceEstimate(kilowattHoursPerHour: "0.15", hourlyCost: "$0.45")
        case "oven":
            return DeviceEstimate(kilowattHoursPerHour: "2.40", hourlyCost: "$7.20")
        case "tv":
            return DeviceEstimate(kilowattHoursPerHour: "0.10", hourlyCost: "$0.30")
        default:
            return nil
        }
    }
}

private enum DetectionMode {
    case camera
    case gallery
}

private enum DeviceSource {
    case camera
    case gallery
    case manual

    var title: String {
        switch self {
        case .camera:
            "Detectado en camara"
        case .gallery:
            "Detectado en galeria"
        case .manual:
            "Manual"
        }
    }
}

private struct TrackedDevice: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let confidence: Float?
    let source: DeviceSource
}

private struct DeviceEstimate {
    let kilowattHoursPerHour: String
    let hourlyCost: String
}

private struct ModeButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.title(15))
            .foregroundStyle(isSelected ? AppTheme.textOnPrimary : AppTheme.textPrimary)
            .frame(height: 46)
            .background(isSelected ? AppTheme.primary : AppTheme.surface)
            .clipShape(Capsule(style: .continuous))
            .overlay {
                Capsule(style: .continuous)
                    .stroke(isSelected ? Color.clear : AppTheme.border, lineWidth: 1)
            }
    }
}

private struct LiveDetectionPreview: View {
    let session: AVCaptureSession
    let detections: [DetectionResult]
    private let videoFrameSize = CGSize(width: 480, height: 640)

    var body: some View {
        GeometryReader { proxy in
            let videoRect = aspectFillRect(imageSize: videoFrameSize, in: proxy.size)

            ZStack {
                CameraPreview(session: session)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                ForEach(detections) { detection in
                    let rect = convertedRect(for: detection.boundingBox, imageRect: videoRect)

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppTheme.surface, lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AppTheme.primary.opacity(0.18))
                        )
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)

                    Text("\(detection.label) \(Int(detection.confidence * 100))%")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textOnPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(AppTheme.primaryDark)
                        .clipShape(Capsule())
                        .position(
                            x: min(max(rect.minX + 80, 55), proxy.size.width - 55),
                            y: max(rect.minY + 12, 16)
                        )
                }
            }
        }
        .frame(height: 420)
        .padding(10)
        .editorialCard()
    }

    private func aspectFillRect(imageSize: CGSize, in containerSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }

        let scale = max(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
        let width = imageSize.width * scale
        let height = imageSize.height * scale
        let originX = (containerSize.width - width) / 2
        let originY = (containerSize.height - height) / 2

        return CGRect(x: originX, y: originY, width: width, height: height)
    }

    private func convertedRect(for boundingBox: CGRect, imageRect: CGRect) -> CGRect {
        let width = boundingBox.width * imageRect.width
        let height = boundingBox.height * imageRect.height
        let x = imageRect.minX + (boundingBox.minX * imageRect.width)
        let y = imageRect.minY + ((1 - boundingBox.minY - boundingBox.height) * imageRect.height)
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

private struct DetectionPreview: View {
    let image: UIImage
    let detections: [DetectionResult]

    var body: some View {
        GeometryReader { proxy in
            let imageSize = image.size
            let fittedRect = aspectFitRect(imageSize: imageSize, in: proxy.size)

            ZStack(alignment: .topLeading) {
                Color.clear

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                ForEach(detections) { detection in
                    let rect = convertedRect(for: detection.boundingBox, imageRect: fittedRect)

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppTheme.primaryDark, lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AppTheme.primary.opacity(0.08))
                        )
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)

                    Text("\(detection.label) \(Int(detection.confidence * 100))%")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textOnPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(AppTheme.primaryDark)
                        .clipShape(Capsule())
                        .position(
                            x: min(max(rect.minX + 80, 55), proxy.size.width - 55),
                            y: max(rect.minY + 12, 16)
                        )
                }
            }
        }
        .frame(height: 360)
        .padding(10)
        .editorialCard()
    }

    private func aspectFitRect(imageSize: CGSize, in containerSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }

        let scale = min(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
        let width = imageSize.width * scale
        let height = imageSize.height * scale
        let originX = (containerSize.width - width) / 2
        let originY = (containerSize.height - height) / 2

        return CGRect(x: originX, y: originY, width: width, height: height)
    }

    private func convertedRect(for boundingBox: CGRect, imageRect: CGRect) -> CGRect {
        let width = boundingBox.width * imageRect.width
        let height = boundingBox.height * imageRect.height
        let x = imageRect.minX + (boundingBox.minX * imageRect.width)
        let y = imageRect.minY + ((1 - boundingBox.minY - boundingBox.height) * imageRect.height)

        return CGRect(x: x, y: y, width: width, height: height)
    }
}

#Preview {
    ConsumptionView()
}

private struct CustomDeviceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var label = ""

    let onSubmit: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Dispositivo") {
                    TextField("Nombre del dispositivo", text: $label)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Agregar dispositivo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSubmit(label.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                    }
                    .disabled(label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
