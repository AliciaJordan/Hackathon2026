import SwiftUI

enum AppTheme {
    static let primary = Color(hex: "4F6B3C")
    static let primaryDark = Color(hex: "2F4A2F")
    static let primaryLight = Color(hex: "93AA7B")
    static let accent = Color(hex: "DCE6D2")
    static let background = Color(hex: "F7F2E8")
    static let surface = Color(hex: "FDFBF6")
    static let surfaceMuted = Color(hex: "E8EDDF")
    static let border = Color(hex: "D6CCBA")
    static let textPrimary = Color(hex: "24281F")
    static let textSecondary = Color(hex: "6E6B60")
    static let textOnPrimary = Color(hex: "F7F2E8")
    static let success = Color(hex: "738257")
    static let warning = Color(hex: "AF8358")
    static let error = Color(hex: "9C6857")

    static let cornerRadius: CGFloat = 24

    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func title(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static let bodyFont = Font.system(size: 15, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 12, weight: .medium, design: .default)
}

struct EditorialCardModifier: ViewModifier {
    var fill: Color = AppTheme.surface
    var radius: CGFloat = AppTheme.cornerRadius

    func body(content: Content) -> some View {
        content
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            }
    }
}

struct EditorialPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.title(16))
            .foregroundStyle(AppTheme.textOnPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(configuration.isPressed ? AppTheme.primaryDark : AppTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .animation(.easeInOut(duration: 0.18), value: configuration.isPressed)
    }
}

struct EditorialSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.title(15))
            .foregroundStyle(AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(configuration.isPressed ? AppTheme.surfaceMuted : AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            }
            .animation(.easeInOut(duration: 0.18), value: configuration.isPressed)
    }
}

extension View {
    func editorialCard(fill: Color = AppTheme.surface, radius: CGFloat = AppTheme.cornerRadius) -> some View {
        modifier(EditorialCardModifier(fill: fill, radius: radius))
    }
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
