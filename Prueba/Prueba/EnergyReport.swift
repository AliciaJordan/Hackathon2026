import Foundation
import CoreLocation
import SwiftUI

enum EnergyReportCategory: String, CaseIterable, Identifiable, Codable {
    case outages
    case highCosts
    case poorInfrastructure
    case general
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .outages:
            "Apagones"
        case .highCosts:
            "Costos"
        case .poorInfrastructure:
            "Infraestructura"
        case .general:
            "Comunidad"
        }
    }
    
    var icon: String {
        switch self {
        case .outages:
            "bolt.slash.fill"
        case .highCosts:
            "dollarsign.circle.fill"
        case .poorInfrastructure:
            "powerplug.fill"
        case .general:
            "bubble.left.and.exclamationmark.bubble.right.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .outages:
            AppTheme.error
        case .highCosts:
            AppTheme.warning
        case .poorInfrastructure:
            AppTheme.primaryDark
        case .general:
            AppTheme.primary
        }
    }
    
    var explanation: String {
        switch self {
        case .outages:
            "Los apagones repetidos afectan seguridad, alimentos y productividad del hogar."
        case .highCosts:
            "Costos altos pueden indicar tarifas pesadas o consumo ineficiente en la zona."
        case .poorInfrastructure:
            "Infraestructura deficiente suele reflejar transformadores, cableado o mantenimiento insuficiente."
        case .general:
            "Las observaciones comunitarias ayudan a detectar patrones que aun no aparecen en los datos tecnicos."
        }
    }
}

struct EnergyReport: Identifiable, Hashable {
    let id: UUID
    let category: EnergyReportCategory
    let title: String
    let summary: String
    let regionName: String
    let latitude: Double
    let longitude: Double
    let intensity: Double
    let affectedHomes: Int
    
    init(
        id: UUID = UUID(),
        category: EnergyReportCategory,
        title: String,
        summary: String,
        regionName: String,
        latitude: Double,
        longitude: Double,
        intensity: Double,
        affectedHomes: Int
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.summary = summary
        self.regionName = regionName
        self.latitude = latitude
        self.longitude = longitude
        self.intensity = intensity
        self.affectedHomes = affectedHomes
    }
}

struct EnergyRegionDensity: Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    let radius: CLLocationDistance
    let intensity: Double
    let color: Color
    let label: String
}
