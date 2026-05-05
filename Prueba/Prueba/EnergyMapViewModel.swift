import Foundation
import MapKit
import Observation

@Observable
final class EnergyMapViewModel {
    var selectedCategory: EnergyReportCategory? = nil
    var selectedReport: EnergyReport?
    var reports: [EnergyReport]
    
    let mexicoRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 23.6345, longitude: -102.5528),
        span: MKCoordinateSpan(latitudeDelta: 18.5, longitudeDelta: 21.5)
    )
    
    init() {
        self.reports = [
            EnergyReport(category: .outages, title: "Cortes recurrentes en temporada de calor", summary: "Vecinas y vecinos reportan apagones breves cada tarde cuando aumenta el uso de ventiladores y aire acondicionado.", regionName: "Monterrey, Nuevo Leon", latitude: 25.6866, longitude: -100.3161, intensity: 0.92, affectedHomes: 84),
            EnergyReport(category: .highCosts, title: "Facturas por encima del promedio", summary: "Los hogares de la zona reportan incrementos fuertes pese a mantener rutinas de consumo similares.", regionName: "Merida, Yucatan", latitude: 20.9674, longitude: -89.5926, intensity: 0.83, affectedHomes: 62),
            EnergyReport(category: .poorInfrastructure, title: "Transformadores saturados", summary: "Se observan bajones de voltaje frecuentes y fallas en postes cercanos durante lluvias.", regionName: "Oaxaca de Juarez, Oaxaca", latitude: 17.0732, longitude: -96.7266, intensity: 0.88, affectedHomes: 53),
            EnergyReport(category: .general, title: "Necesidad de iluminacion eficiente", summary: "La comunidad pide alumbrado mas eficiente y programas de ahorro para calles y espacios comunes.", regionName: "Puebla, Puebla", latitude: 19.0414, longitude: -98.2063, intensity: 0.58, affectedHomes: 40),
            EnergyReport(category: .outages, title: "Interrupciones nocturnas continuas", summary: "Los apagones duran pocos minutos, pero ocurren varias veces por semana y afectan refrigeracion domestica.", regionName: "Villahermosa, Tabasco", latitude: 17.9895, longitude: -92.9475, intensity: 0.79, affectedHomes: 48),
            EnergyReport(category: .highCosts, title: "Tarifas que limitan el uso basico", summary: "Las familias reducen uso de electrodomesticos esenciales por miedo a una factura dificil de cubrir.", regionName: "Tijuana, Baja California", latitude: 32.5149, longitude: -117.0382, intensity: 0.74, affectedHomes: 67),
            EnergyReport(category: .poorInfrastructure, title: "Cableado envejecido en zona costera", summary: "El viento y la humedad provocan reportes sobre variaciones de corriente y riesgos de seguridad.", regionName: "Veracruz, Veracruz", latitude: 19.1738, longitude: -96.1342, intensity: 0.81, affectedHomes: 58),
            EnergyReport(category: .general, title: "Quejas por consumo comun sin control", summary: "Se solicita monitoreo compartido en edificios para detectar desperdicios en areas comunes.", regionName: "Ciudad de Mexico", latitude: 19.4326, longitude: -99.1332, intensity: 0.64, affectedHomes: 71)
        ]
    }
    
    var filteredReports: [EnergyReport] {
        guard let selectedCategory else { return reports }
        return reports.filter { $0.category == selectedCategory }
    }
    
    var densityOverlays: [EnergyRegionDensity] {
        filteredReports.map { report in
            EnergyRegionDensity(
                latitude: report.latitude,
                longitude: report.longitude,
                radius: 30000 + (report.intensity * 26000),
                intensity: report.intensity,
                color: report.category.color,
                label: report.regionName
            )
        }
    }
    
    var activeSummary: String {
        if let selectedCategory {
            return selectedCategory.explanation
        }
        return "Explora reportes comunitarios para detectar zonas con apagones, costos elevados o infraestructura fragil."
    }
    
    func toggle(category: EnergyReportCategory?) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
        if let selectedReport, !filteredReports.contains(selectedReport) {
            self.selectedReport = nil
        }
    }
    
    func select(_ report: EnergyReport) {
        selectedReport = report
    }

    func addReport(state: String, situation: String, category: EnergyReportCategory) {
        let normalizedState = state.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedSituation = situation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedState.isEmpty, !normalizedSituation.isEmpty else { return }

        let coordinate = coordinate(for: normalizedState)
        let report = EnergyReport(
            category: category,
            title: title(for: category),
            summary: normalizedSituation,
            regionName: normalizedState,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            intensity: 0.70,
            affectedHomes: 0
        )

        reports.insert(report, at: 0)
        selectedCategory = nil
        selectedReport = report
    }

    private func title(for category: EnergyReportCategory) -> String {
        switch category {
        case .outages:
            "Reporte de falta de luz"
        case .highCosts:
            "Reporte de costo elevado"
        case .poorInfrastructure:
            "Reporte de infraestructura electrica"
        case .general:
            "Reporte ciudadano"
        }
    }

    private func coordinate(for state: String) -> CLLocationCoordinate2D {
        let coordinates: [String: CLLocationCoordinate2D] = [
            "aguascalientes": CLLocationCoordinate2D(latitude: 21.8853, longitude: -102.2916),
            "baja california": CLLocationCoordinate2D(latitude: 32.6245, longitude: -115.4523),
            "baja california sur": CLLocationCoordinate2D(latitude: 24.1426, longitude: -110.3128),
            "campeche": CLLocationCoordinate2D(latitude: 19.8301, longitude: -90.5349),
            "chiapas": CLLocationCoordinate2D(latitude: 16.7516, longitude: -93.1029),
            "chihuahua": CLLocationCoordinate2D(latitude: 28.6320, longitude: -106.0691),
            "ciudad de mexico": CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
            "coahuila": CLLocationCoordinate2D(latitude: 25.4267, longitude: -101.0053),
            "colima": CLLocationCoordinate2D(latitude: 19.2452, longitude: -103.7241),
            "durango": CLLocationCoordinate2D(latitude: 24.0277, longitude: -104.6532),
            "estado de mexico": CLLocationCoordinate2D(latitude: 19.2938, longitude: -99.6532),
            "guanajuato": CLLocationCoordinate2D(latitude: 21.0190, longitude: -101.2574),
            "guerrero": CLLocationCoordinate2D(latitude: 17.5515, longitude: -99.5006),
            "hidalgo": CLLocationCoordinate2D(latitude: 20.0911, longitude: -98.7624),
            "jalisco": CLLocationCoordinate2D(latitude: 20.6597, longitude: -103.3496),
            "michoacan": CLLocationCoordinate2D(latitude: 19.7008, longitude: -101.1844),
            "morelos": CLLocationCoordinate2D(latitude: 18.9242, longitude: -99.2216),
            "nayarit": CLLocationCoordinate2D(latitude: 21.5085, longitude: -104.8953),
            "nuevo leon": CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
            "oaxaca": CLLocationCoordinate2D(latitude: 17.0732, longitude: -96.7266),
            "puebla": CLLocationCoordinate2D(latitude: 19.0414, longitude: -98.2063),
            "queretaro": CLLocationCoordinate2D(latitude: 20.5888, longitude: -100.3899),
            "quintana roo": CLLocationCoordinate2D(latitude: 21.1619, longitude: -86.8515),
            "san luis potosi": CLLocationCoordinate2D(latitude: 22.1565, longitude: -100.9855),
            "sinaloa": CLLocationCoordinate2D(latitude: 24.8091, longitude: -107.3940),
            "sonora": CLLocationCoordinate2D(latitude: 29.0729, longitude: -110.9559),
            "tabasco": CLLocationCoordinate2D(latitude: 17.9895, longitude: -92.9475),
            "tamaulipas": CLLocationCoordinate2D(latitude: 23.7369, longitude: -99.1411),
            "tlaxcala": CLLocationCoordinate2D(latitude: 19.3182, longitude: -98.2375),
            "veracruz": CLLocationCoordinate2D(latitude: 19.1738, longitude: -96.1342),
            "yucatan": CLLocationCoordinate2D(latitude: 20.9674, longitude: -89.5926),
            "zacatecas": CLLocationCoordinate2D(latitude: 22.7709, longitude: -102.5833)
        ]

        let key = state.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).lowercased()
        return coordinates[key] ?? mexicoRegion.center
    }
}
