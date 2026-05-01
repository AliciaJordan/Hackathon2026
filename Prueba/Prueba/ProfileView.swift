import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var isEditing = false
    @State private var editName = ""
    @State private var editBio = ""
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        profileHeader
                        
                        VStack(spacing: 20) {
                            profileStats
                            menuSections
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isEditing) {
                editProfileSheet
            }
            .alert("Cerrar Sesion", isPresented: $showingLogoutAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Cerrar Sesion", role: .destructive) {
                    appState.logout()
                }
            } message: {
                Text("Estas seguro de que quieres cerrar sesion?")
            }
        }
    }
    
    // MARK: - Header
    
    private var profileHeader: some View {
        VStack(spacing: 0) {
        ZStack(alignment: .bottom) {
            // Background gradient
            AppTheme.headerGradient
                .frame(height: 200)
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: 32,
                        bottomTrailingRadius: 32
                    )
                )
            
            VStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(AppTheme.cardBackground)
                        .frame(width: 96, height: 96)
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                    
                    Text(appState.currentUser?.avatarInitials ?? "??")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(AppTheme.primary)
                }
                .offset(y: 48)
            }
        }
        .padding(.bottom, 56)
        .overlay(alignment: .topTrailing) {
            Button {
                editName = appState.currentUser?.name ?? ""
                editBio = appState.currentUser?.bio ?? ""
                isEditing = true
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.trailing, 20)
            .padding(.top, 56)
        }

        // Name and info below the avatar offset
        VStack(spacing: 6) {
            Text(appState.currentUser?.name ?? "Usuario")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(appState.currentUser?.email ?? "")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)

            if let bio = appState.currentUser?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 4)
            }
        }
        }
    }
    
    // MARK: - Stats
    
    private var profileStats: some View {
        HStack(spacing: 0) {
            ProfileStatView(value: "24", label: "Proyectos")
            Divider().frame(height: 40)
            ProfileStatView(value: "156", label: "Tareas")
            Divider().frame(height: 40)
            ProfileStatView(value: "12", label: "Equipos")
        }
        .padding(.vertical, 16)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Menu Sections
    
    private var menuSections: some View {
        VStack(spacing: 16) {
            // Account section
            MenuSection(title: "Cuenta") {
                MenuRow(icon: "person.fill", title: "Informacion Personal", color: AppTheme.primary)
                MenuRow(icon: "bell.fill", title: "Notificaciones", color: AppTheme.accent)
                MenuRow(icon: "lock.fill", title: "Privacidad y Seguridad", color: Color(hex: "7C3AED"))
            }
            
            // Preferences section
            MenuSection(title: "Preferencias") {
                MenuRow(icon: "paintbrush.fill", title: "Apariencia", color: AppTheme.warning)
                MenuRow(icon: "globe", title: "Idioma", color: AppTheme.success)
                MenuRow(icon: "questionmark.circle.fill", title: "Ayuda y Soporte", color: AppTheme.textSecondary)
            }
            
            // Logout
            Button {
                showingLogoutAlert = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.error)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text("Cerrar Sesion")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.error)
                    
                    Spacer()
                }
                .padding(16)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Edit Sheet
    
    private var editProfileSheet: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.textSecondary)
                        CustomTextField(icon: "person.fill", placeholder: "Tu nombre", text: $editName)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.textSecondary)
                        TextEditor(text: $editBio)
                            .frame(height: 100)
                            .padding(12)
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.primary.opacity(0.15), lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                }
                .padding(24)
            }
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

// MARK: - Supporting Views

struct ProfileStatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                content
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
            .padding(.horizontal, 20)
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
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                    .frame(width: 34, height: 34)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Spacer()
                
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
    let state = AppState()
    state.currentUser = .sample
    return ProfileView().environment(state)
}
