import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var notificationsEnabled = true
    @State private var smartAlertsEnabled = true
    @State private var standbyProtection = true
    @State private var selectedLanguage = "Espanol"

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Control")
                        .font(AppTheme.display(40))
                        .foregroundStyle(AppTheme.textPrimary)

                    settingsSection(title: "Energia") {
                        SettingsToggleRow(
                            icon: "bell.fill",
                            title: "Notificaciones motivacionales",
                            color: AppTheme.primary,
                            isOn: $notificationsEnabled
                        )
                        dividerInset
                        SettingsToggleRow(
                            icon: "bolt.badge.clock.fill",
                            title: "Alertas en horas pico",
                            color: AppTheme.warning,
                            isOn: $smartAlertsEnabled
                        )
                        dividerInset
                        SettingsToggleRow(
                            icon: "powerplug.fill",
                            title: "Proteccion contra standby",
                            color: AppTheme.success,
                            isOn: $standbyProtection
                        )
                    }

                    settingsSection(title: "Automatizacion") {
                        SettingsNavRow(icon: "togglepower", title: "Escenas inteligentes", subtitle: "3 activas", color: AppTheme.primaryDark)
                        dividerInset
                        SettingsNavRow(icon: "timer", title: "Apagado automatico", subtitle: "22:30", color: AppTheme.primary)
                        dividerInset
                        SettingsNavRow(icon: "wifi", title: "Dispositivos conectados", subtitle: "8 hogares", color: AppTheme.textSecondary)
                    }

                    settingsSection(title: "Educacion") {
                        SettingsNavRow(icon: "book.fill", title: "Mini lecciones", subtitle: "4 nuevas", color: AppTheme.primary)
                        dividerInset
                        SettingsNavRow(icon: "flag.fill", title: "Retos semanales", subtitle: "Reinicia lunes", color: AppTheme.warning)
                        dividerInset
                        SettingsNavRow(icon: "globe", title: "Idioma", subtitle: selectedLanguage, color: AppTheme.success)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var dividerInset: some View {
        Divider()
            .overlay(AppTheme.border)
            .padding(.leading, 56)
    }

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppTheme.captionFont)
                .textCase(.uppercase)
                .tracking(1.6)
                .foregroundStyle(AppTheme.textSecondary)

            VStack(spacing: 0) {
                content()
            }
            .editorialCard()
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 24)

            Text(title)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppTheme.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SettingsNavRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        Button {} label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(color)
                    .frame(width: 24)

                Text(title)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
