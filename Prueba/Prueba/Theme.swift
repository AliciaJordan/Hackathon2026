import SwiftUI

enum AppTheme {
    // Primary blues - soft pastels
    static let primary = Color(hex: "6BA3F7")
    static let primaryDark = Color(hex: "4A8AF5")
    static let primaryLight = Color(hex: "A8CCFF")
    static let accent = Color(hex: "7EC8E3")

    // Backgrounds - warm pastel blue tints
    static let background = Color(hex: "EDF3FF")
    static let cardBackground = Color(hex: "F8FAFF")
    static let darkCard = Color(hex: "3B5998")

    // Text
    static let textPrimary = Color(hex: "2D3A4A")
    static let textSecondary = Color(hex: "8E9BB3")
    static let textOnPrimary = Color.white

    // Status - pastel tones
    static let success = Color(hex: "7DD3A8")
    static let warning = Color(hex: "F7C97E")
    static let error = Color(hex: "F28B8B")

    // Gradients - soft blue pastels
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "7EB6FF"), Color(hex: "5B9CF5"), Color(hex: "8EC5FC")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let headerGradient = LinearGradient(
        colors: [Color(hex: "89B4FA"), Color(hex: "6BA3F7"), Color(hex: "A8D4FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
