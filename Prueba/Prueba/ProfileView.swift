import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var isEditing = false
    @State private var editName = ""
    @State private var editBio = ""
    @State private var showingLogoutAlert = false
    @State private var notificationsEnabled = true
    @State private var smartAlertsEnabled = true
    @State private var standbyProtection = true

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    topTitle
                    profileHeader
                    profileStats
                    preferencesSection
                    menuSections
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 110)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isEditing) {
                editProfileSheet
            }
            .alert("Cerrar Sesion", isPresented: $showingLogoutAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Cerrar Sesion", role: .destructive) {
                    appState.logout()
                }
            } message: {
                Text("Estas seguro de que quieres salir de tu panel de energia?")
            }
        }
    }

    private var topTitle: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Perfil / Control")
                .font(AppTheme.display(38))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Tu cuenta y tus automatizaciones en un solo lugar.")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(AppTheme.surfaceMuted)
                        .frame(width: 82, height: 82)

                    Text(appState.currentUser?.avatarInitials ?? "U")
                        .font(AppTheme.title(26))
                        .foregroundStyle(AppTheme.primaryDark)
                }

                Spacer()

                Button {
                    editName = appState.currentUser?.name ?? ""
                    editBio = appState.currentUser?.bio ?? ""
                    isEditing = true
                } label: {
                    Text("Editar")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.primaryDark)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppTheme.surfaceMuted)
                        .clipShape(Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(appState.currentUser?.name ?? "Usuario")
                    .font(AppTheme.title(28))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(appState.currentUser?.email ?? "")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)

                if let bio = appState.currentUser?.bio, !bio.isEmpty {
                    Text(bio)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding(24)
        .editorialCard(fill: AppTheme.surfaceMuted, radius: 30)
    }

    private var profileStats: some View {
        HStack(spacing: 0) {
            ProfileStatView(value: "320", label: "Eco-puntos")
            Divider().overlay(AppTheme.border)
            ProfileStatView(value: "7", label: "Racha")
            Divider().overlay(AppTheme.border)
            ProfileStatView(value: "5", label: "Badges")
        }
        .padding(.vertical, 14)
        .editorialCard()
    }

    private var menuSections: some View {
        VStack(spacing: 18) {
            MenuSection(title: "Resumen") {
                MenuRow(icon: "leaf.fill", title: "Habitos sostenibles", color: AppTheme.primary)
                Divider().overlay(AppTheme.border).padding(.leading, 56)
                MenuRow(icon: "chart.line.uptrend.xyaxis", title: "Impacto mensual", color: AppTheme.success)
                Divider().overlay(AppTheme.border).padding(.leading, 56)
                MenuRow(icon: "battery.75", title: "Reducir consumo en espera", color: AppTheme.primaryDark)
            }

            Button {
                showingLogoutAlert = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.error)
                        .frame(width: 24)

                    Text("Cerrar Sesion")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.error)

                    Spacer()
                }
                .padding(18)
            }
            .editorialCard()
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preferencias")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1.6)

            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "bell.fill",
                    title: "Notificaciones motivacionales",
                    color: AppTheme.primary,
                    isOn: $notificationsEnabled
                )
                Divider().overlay(AppTheme.border).padding(.leading, 56)
                SettingsToggleRow(
                    icon: "bolt.badge.clock.fill",
                    title: "Alertas en horas pico",
                    color: AppTheme.warning,
                    isOn: $smartAlertsEnabled
                )
                Divider().overlay(AppTheme.border).padding(.leading, 56)
                SettingsToggleRow(
                    icon: "powerplug.fill",
                    title: "Proteccion contra standby",
                    color: AppTheme.success,
                    isOn: $standbyProtection
                )
            }
            .editorialCard()
        }
    }

    private var editProfileSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                    CustomTextField(icon: "person", placeholder: "Tu nombre", text: $editName)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                    TextEditor(text: $editBio)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(height: 120)
                        .padding(12)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(AppTheme.border, lineWidth: 1)
                        }
                }

                Spacer()
            }
            .padding(24)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { isEditing = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        appState.currentUser?.name = editName
                        appState.currentUser?.bio = editBio
                        isEditing = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct ProfileStatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTheme.title(24))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1.6)

            VStack(spacing: 0) {
                content
            }
            .editorialCard()
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
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
    let state = AppState()
    state.currentUser = .sample
    return ProfileView().environment(state)
}
