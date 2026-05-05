import Foundation
import MapKit
import Observation

@Observable
final class EnergyMapViewModel {
    var selectedCategory: EnergyReportCategory? = nil
    var selectedReport: EnergyReport?
    
    let mexicoRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 23.6345, longitude: -102.5528),
        span: MKCoordinateSpan(latitudeDelta: 18.5, longitudeDelta: 21.5)
    )
    
    let reports: [EnergyReport] = [
        EnergyReport(category: .outages, title: "Cortes recurrentes en temporada de calor", summary: "Vecinas y vecinos reportan apagones breves cada tarde cuando aumenta el uso de ventiladores y aire acondicionado.", regionName: "Monterrey, Nuevo Leon", latitude: 25.6866, longitude: -100.3161, intensity: 0.92, affectedHomes: 84),
        EnergyReport(category: .highCosts, title: "Facturas por encima del promedio", summary: "Los hogares de la zona reportan incrementos fuertes pese a mantener rutinas de consumo similares.", regionName: "Merida, Yucatan", latitude: 20.9674, longitude: -89.5926, intensity: 0.83, affectedHomes: 62),
        EnergyReport(category: .poorInfrastructure, title: "Transformadores saturados", summary: "Se observan bajones de voltaje frecuentes y fallas en postes cercanos durante lluvias.", regionName: "Oaxaca de Juarez, Oaxaca", latitude: 17.0732, longitude: -96.7266, intensity: 0.88, affectedHomes: 53),
        EnergyReport(category: .general, title: "Necesidad de iluminacion eficiente", summary: "La comunidad pide alumbrado mas eficiente y programas de ahorro para calles y espacios comunes.", regionName: "Puebla, Puebla", latitude: 19.0414, longitude: -98.2063, intensity: 0.58, affectedHomes: 40),
        EnergyReport(category: .outages, title: "Interrupciones nocturnas continuas", summary: "Los apagones duran pocos minutos, pero ocurren varias veces por semana y afectan refrigeracion domestica.", regionName: "Villahermosa, Tabasco", latitude: 17.9895, longitude: -92.9475, intensity: 0.79, affectedHomes: 48),
        EnergyReport(category: .highCosts, title: "Tarifas que limitan el uso basico", summary: "Las familias reducen uso de electrodomesticos esenciales por miedo a una factura dificil de cubrir.", regionName: "Tijuana, Baja California", latitude: 32.5149, longitude: -117.0382, intensity: 0.74, affectedHomes: 67),
        EnergyReport(category: .poorInfrastructure, title: "Cableado envejecido en zona costera", summary: "El viento y la humedad provocan reportes sobre variaciones de corriente y riesgos de seguridad.", regionName: "Veracruz, Veracruz", latitude: 19.1738, longitude: -96.1342, intensity: 0.81, affectedHomes: 58),
        EnergyReport(category: .general, title: "Quejas por consumo comun sin control", summary: "Se solicita monitoreo compartido en edificios para detectar desperdicios en areas comunes.", regionName: "Ciudad de Mexico", latitude: 19.4326, longitude: -99.1332, intensity: 0.64, affectedHomes: 71)
    ]
    
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
}
