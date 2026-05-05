import MapKit
import SwiftUI

struct MapView: View {
    @State private var viewModel = EnergyMapViewModel()
    @State private var selectedReport: EnergyReport?
    @State private var showingReportForm = false
    @State private var recenterToken = 0

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    screenTitle
                    headerCard
                    filtersRow
                    mapCard
                    actionsRow
                    if let selectedReport = selectedReport ?? viewModel.selectedReport {
                        reportSummaryCard(report: selectedReport)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        communityCard
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 110)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .animation(.easeInOut(duration: 0.25), value: selectedReport?.id)
            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedCategory?.rawValue)
            .sheet(isPresented: $showingReportForm) {
                ReportFormSheet { state, situation, category in
                    viewModel.addReport(state: state, situation: situation, category: category)
                    selectedReport = viewModel.selectedReport
                    recenterToken += 1
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .onChange(of: viewModel.selectedReport?.id) { _, _ in
                selectedReport = viewModel.selectedReport
            }
            .onChange(of: selectedReport?.id) { _, _ in
                viewModel.selectedReport = selectedReport
            }
        }
    }

    private var screenTitle: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mapa")
                .font(AppTheme.display(40))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Reportes ciudadanos de energia en Mexico")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Infraestructura y consumo por region")
                    .font(AppTheme.title(20))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text("\(viewModel.filteredReports.count) reportes")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.primaryDark)
            }
            Text(viewModel.activeSummary)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(20)
        .editorialCard()
    }

    private var filtersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(title: "Todo", icon: "circle.grid.2x2", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.toggle(category: nil)
                }
                ForEach(EnergyReportCategory.allCases) { category in
                    filterChip(title: category.title, icon: category.icon, isSelected: viewModel.selectedCategory == category) {
                        viewModel.toggle(category: category)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var mapCard: some View {
        ZStack(alignment: .topTrailing) {
            ReportsMapRepresentable(
                reports: viewModel.filteredReports,
                overlays: viewModel.densityOverlays,
                mexicoRegion: viewModel.mexicoRegion,
                selectedReport: $selectedReport,
                recenterToken: recenterToken
            )
            .frame(height: 380)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            }

            VStack(alignment: .trailing, spacing: 8) {
                mapLegend
                Button {
                    showingReportForm = true
                } label: {
                    Label("Nuevo reporte", systemImage: "plus.bubble.fill")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textOnPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppTheme.primaryDark)
                        .clipShape(Capsule())
                }
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedReport = nil
                        viewModel.selectedReport = nil
                        recenterToken += 1
                    }
                } label: {
                    Label("Mexico", systemImage: "location.north.line")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.primaryDark)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppTheme.surface)
                        .clipShape(Capsule())
                }
            }
            .padding(14)
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
            if let selectedReport, !viewModel.filteredReports.contains(selectedReport) {
                self.selectedReport = nil
                viewModel.selectedReport = nil
            }
        }
    }

    private var actionsRow: some View {
        HStack(spacing: 12) {
            Button {
                showingReportForm = true
            } label: {
                Label("Reportar", systemImage: "square.and.pencil")
            }
            .buttonStyle(EditorialPrimaryButtonStyle())

            Button {
                selectedReport = nil
                viewModel.selectedReport = nil
                recenterToken += 1
            } label: {
                Label("Limpiar", systemImage: "xmark")
            }
            .buttonStyle(EditorialSecondaryButtonStyle())
        }
    }

    private var mapLegend: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppTheme.primary.opacity(0.25))
                .frame(width: 12, height: 12)
            Text("Mayor densidad = color mas intenso")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.surface)
        .clipShape(Capsule())
    }

    private var communityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vista comunitaria")
                .font(AppTheme.title(20))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Toca un pin para leer un resumen del reporte. Las capas suaves muestran donde la comunidad concentra mas observaciones.")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .editorialCard(fill: AppTheme.surfaceMuted)
    }

    private func reportSummaryCard(report: EnergyReport) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(report.title)
                        .font(AppTheme.title(22))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(report.regionName)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                Text("\(report.affectedHomes) hogares")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.primaryDark)
            }

            Text(report.summary)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)

            Text(reportStatus(for: report))
                .font(AppTheme.title(16))
                .foregroundStyle(report.category == .outages ? AppTheme.error : AppTheme.primaryDark)

            HStack(spacing: 12) {
                summaryPill(title: report.category.title, color: report.category.color)
                summaryPill(title: "Intensidad \(Int(report.intensity * 100))%", color: AppTheme.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .editorialCard()
    }

    private func filterChip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(AppTheme.captionFont)
            .foregroundStyle(isSelected ? AppTheme.textOnPrimary : AppTheme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? AppTheme.primaryDark : AppTheme.surface)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isSelected ? Color.clear : AppTheme.border, lineWidth: 1)
            }
        }
    }

    private func summaryPill(title: String, color: Color) -> some View {
        Text(title)
            .font(AppTheme.captionFont)
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.10))
            .clipShape(Capsule())
    }

    private func reportStatus(for report: EnergyReport) -> String {
        switch report.category {
        case .outages:
            "Estado: sin luz reportada"
        case .highCosts:
            "Estado: reporte por costo elevado"
        case .poorInfrastructure:
            "Estado: infraestructura electrica en riesgo"
        case .general:
            "Estado: reporte comunitario"
        }
    }
}

private struct ReportsMapRepresentable: UIViewRepresentable {
    let reports: [EnergyReport]
    let overlays: [EnergyRegionDensity]
    let mexicoRegion: MKCoordinateRegion
    @Binding var selectedReport: EnergyReport?
    let recenterToken: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedReport: $selectedReport)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.setRegion(mexicoRegion, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.syncAnnotations(on: mapView, reports: reports)
        context.coordinator.syncOverlays(on: mapView, overlays: overlays)

        if context.coordinator.lastRecenterToken != recenterToken {
            context.coordinator.lastRecenterToken = recenterToken
            mapView.setRegion(mexicoRegion, animated: true)
        }

        if let selectedReport {
            if let annotation = context.coordinator.annotationsByID[selectedReport.id] {
                mapView.selectAnnotation(annotation, animated: true)
                mapView.setCenter(annotation.coordinate, animated: true)
            }
        } else {
            mapView.selectedAnnotations.forEach { mapView.deselectAnnotation($0, animated: true) }
        }
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ReportsMapRepresentable
        @Binding var selectedReport: EnergyReport?
        var lastRecenterToken = 0
        var annotationsByID: [UUID: ReportAnnotation] = [:]
        var overlaysByID: [String: DensityCircle] = [:]

        init(selectedReport: Binding<EnergyReport?>) {
            self.parent = ReportsMapRepresentable(
                reports: [],
                overlays: [],
                mexicoRegion: MKCoordinateRegion(),
                selectedReport: selectedReport,
                recenterToken: 0
            )
            self._selectedReport = selectedReport
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? ReportAnnotation else { return nil }
            let identifier = "ReportMarker"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            view.canShowCallout = true
            view.markerTintColor = UIColor(annotation.report.category.color)
            view.glyphImage = UIImage(systemName: annotation.report.category.icon)
            view.displayPriority = .required
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let circle = overlay as? DensityCircle else {
                return MKOverlayRenderer(overlay: overlay)
            }
            let renderer = MKCircleRenderer(circle: circle)
            renderer.fillColor = circle.tintColor
            renderer.strokeColor = .clear
            return renderer
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let annotation = annotation as? ReportAnnotation else { return }
            selectedReport = annotation.report
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation as? ReportAnnotation else { return }
            selectedReport = annotation.report
            mapView.setCenter(annotation.coordinate, animated: true)
        }

        func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
            guard annotation is ReportAnnotation else { return }
            selectedReport = nil
        }

        func syncAnnotations(on mapView: MKMapView, reports: [EnergyReport]) {
            let incomingIDs = Set(reports.map(\.id))
            let staleIDs = Set(annotationsByID.keys).subtracting(incomingIDs)
            for id in staleIDs {
                if let annotation = annotationsByID.removeValue(forKey: id) {
                    mapView.removeAnnotation(annotation)
                }
            }

            for report in reports {
                if let annotation = annotationsByID[report.id] {
                    annotation.report = report
                    annotation.coordinate = CLLocationCoordinate2D(latitude: report.latitude, longitude: report.longitude)
                    annotation.title = report.title
                    annotation.subtitle = report.regionName
                } else {
                    let annotation = ReportAnnotation(report: report)
                    annotation.coordinate = CLLocationCoordinate2D(latitude: report.latitude, longitude: report.longitude)
                    annotation.title = report.title
                    annotation.subtitle = report.regionName
                    annotationsByID[report.id] = annotation
                    mapView.addAnnotation(annotation)
                }
            }
        }

        func syncOverlays(on mapView: MKMapView, overlays: [EnergyRegionDensity]) {
            let incomingIDs = Set(overlays.map(\.label))
            let staleIDs = Set(overlaysByID.keys).subtracting(incomingIDs)
            for id in staleIDs {
                if let overlay = overlaysByID.removeValue(forKey: id) {
                    mapView.removeOverlay(overlay)
                }
            }

            for overlay in overlays {
                if overlaysByID[overlay.label] == nil {
                    let circle = DensityCircle(
                        center: CLLocationCoordinate2D(latitude: overlay.latitude, longitude: overlay.longitude),
                        radius: overlay.radius
                    )
                    circle.tintColor = UIColor(overlay.color.opacity(0.26))
                    overlaysByID[overlay.label] = circle
                    mapView.addOverlay(circle)
                }
            }
        }
    }
}

private final class ReportAnnotation: MKPointAnnotation {
    var report: EnergyReport

    init(report: EnergyReport) {
        self.report = report
        super.init()
    }
}

private final class DensityCircle: MKCircle {
    var tintColor: UIColor = .clear
}

#Preview {
    MapView()
}

private struct ReportFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var state = ""
    @State private var situation = ""
    @State private var category: EnergyReportCategory = .outages

    let onSubmit: (String, String, EnergyReportCategory) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Ubicacion") {
                    TextField("Estado", text: $state)
                        .textInputAutocapitalization(.words)
                }

                Section("Situacion") {
                    Picker("Tipo", selection: $category) {
                        ForEach(EnergyReportCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }

                    TextField("Describe que esta pasando", text: $situation, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Nuevo reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSubmit(state, situation, category)
                        dismiss()
                    }
                    .disabled(state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || situation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
