import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    @State private var shakeOffset: CGFloat = 0
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Habitat")
                        .font(AppTheme.captionFont)
                        .textCase(.uppercase)
                        .tracking(2)
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("Energia serena para la vida diaria.")
                        .font(AppTheme.display(42))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Aprende, automatiza y reduce tu consumo con pasos simples.")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: 290, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Acceso")
                        .font(AppTheme.title(20))
                        .foregroundStyle(AppTheme.textPrimary)

                    CustomTextField(
                        icon: "envelope",
                        placeholder: "Correo electronico",
                        text: $email,
                        isSecure: false
                    )
                    .focused($focusedField, equals: .email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                    CustomTextField(
                        icon: "lock",
                        placeholder: "Contrasena",
                        text: $password,
                        isSecure: !isPasswordVisible,
                        trailingIcon: isPasswordVisible ? "eye.slash" : "eye",
                        trailingAction: { isPasswordVisible.toggle() }
                    )
                    .focused($focusedField, equals: .password)

                    HStack {
                        Spacer()
                        Button("Recuperar acceso") {}
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.primaryDark)
                    }
                }
                .padding(22)
                .editorialCard()
                .offset(x: shakeOffset)

                Button {
                    login()
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(AppTheme.textOnPrimary)
                        }
                        Text("Entrar a mi hábitat")
                    }
                }
                .buttonStyle(EditorialPrimaryButtonStyle())
                .disabled(isLoading)

                HStack {
                    Rectangle().fill(AppTheme.border).frame(height: 1)
                    Text("o continua con")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                    Rectangle().fill(AppTheme.border).frame(height: 1)
                }

                HStack(spacing: 12) {
                    SocialButton(icon: "apple.logo", label: "Apple")
                    SocialButton(icon: "bolt.shield", label: "Invitado")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Notas")
                        .font(AppTheme.captionFont)
                        .textCase(.uppercase)
                        .tracking(1.6)
                        .foregroundStyle(AppTheme.textSecondary)
                    Label("Detecta consumo oculto antes de que se vuelva costumbre", systemImage: "powerplug")
                    Label("Recibe sugerencias para evitar horas pico", systemImage: "sun.max")
                    Label("Convierte ahorro en rachas y logros semanales", systemImage: "battery.100.bolt")
                }
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
                .padding(22)
                .editorialCard(fill: AppTheme.surfaceMuted)

                HStack(spacing: 4) {
                    Text("No tienes cuenta?")
                        .foregroundStyle(AppTheme.textSecondary)
                    Button("Crea tu plan") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            appState.showingSignUp = true
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primaryDark)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    private func login() {
        focusedField = nil
        guard !email.isEmpty, !password.isEmpty else {
            withAnimation(.default) {
                shakeOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.2)) {
                    shakeOffset = 0
                }
            }
            return
        }

        isLoading = true
        appState.login(email: email, password: password)
        isLoading = false
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var trailingIcon: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.primaryDark)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textPrimary)
            }

            if let trailingIcon, let trailingAction {
                Button(action: trailingAction) {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        }
    }
}

struct SocialButton: View {
    let icon: String
    let label: String

    var body: some View {
        Button {} label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(AppTheme.title(15))
            }
        }
        .buttonStyle(EditorialSecondaryButtonStyle())
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
