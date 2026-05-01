import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var notificationsEnabled = true
    @State private var darkMode = false
    @State private var biometricEnabled = false
    @State private var selectedLanguage = "Espanol"
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // General
                        settingsSection(title: "GENERAL") {
                            SettingsToggleRow(
                                icon: "bell.fill",
                                title: "Notificaciones",
                                color: AppTheme.primary,
                                isOn: $notificationsEnabled
                            )
                            Divider().padding(.leading, 62)
                            SettingsToggleRow(
                                icon: "moon.fill",
                                title: "Modo Oscuro",
                                color: Color(hex: "7C3AED"),
                                isOn: $darkMode
                            )
                            Divider().padding(.leading, 62)
                            SettingsToggleRow(
                                icon: "faceid",
                                title: "Autenticacion Biometrica",
                                color: AppTheme.success,
                                isOn: $biometricEnabled
                            )
                        }
                        
                        // Data
                        settingsSection(title: "DATOS") {
                            SettingsNavRow(icon: "icloud.fill", title: "Sincronizacion", subtitle: "Activada", color: AppTheme.accent)
                            Divider().padding(.leading, 62)
                            SettingsNavRow(icon: "arrow.down.circle.fill", title: "Descargar Datos", subtitle: "250 MB", color: AppTheme.primary)
                            Divider().padding(.leading, 62)
                            SettingsNavRow(icon: "trash.fill", title: "Borrar Cache", subtitle: "45 MB", color: AppTheme.error)
                        }
                        
                        // About
                        settingsSection(title: "ACERCA DE") {
                            SettingsNavRow(icon: "info.circle.fill", title: "Version", subtitle: "1.0.0", color: AppTheme.textSecondary)
                            Divider().padding(.leading, 62)
                            SettingsNavRow(icon: "doc.text.fill", title: "Terminos de Servicio", subtitle: "", color: AppTheme.primary)
                            Divider().padding(.leading, 62)
                            SettingsNavRow(icon: "hand.raised.fill", title: "Politica de Privacidad", subtitle: "", color: AppTheme.warning)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
            .padding(.horizontal, 20)
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
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 9))
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppTheme.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                    .frame(width: 34, height: 34)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Spacer()
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
