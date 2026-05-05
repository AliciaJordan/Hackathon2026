import SwiftUI

struct SignUpView: View {
    @Environment(AppState.self) private var appState
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var acceptedTerms = false
    @FocusState private var focusedField: Field?

    enum Field { case name, email, password, confirm }

    var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && passwordsMatch && acceptedTerms
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nuevo perfil")
                        .font(AppTheme.captionFont)
                        .textCase(.uppercase)
                        .tracking(2)
                        .foregroundStyle(AppTheme.textSecondary)

                    Text("Crea tu espacio sostenible.")
                        .font(AppTheme.display(40))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Activa recomendaciones personalizadas, retos y automatizaciones de ahorro.")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: 300, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Registro")
                        .font(AppTheme.title(20))
                        .foregroundStyle(AppTheme.textPrimary)

                    CustomTextField(
                        icon: "person",
                        placeholder: "Nombre completo",
                        text: $name
                    )
                    .focused($focusedField, equals: .name)
                    .textInputAutocapitalization(.words)

                    CustomTextField(
                        icon: "envelope",
                        placeholder: "Correo electronico",
                        text: $email
                    )
                    .focused($focusedField, equals: .email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                    CustomTextField(
                        icon: "lock",
                        placeholder: "Contrasena",
                        text: $password,
                        isSecure: true
                    )
                    .focused($focusedField, equals: .password)

                    CustomTextField(
                        icon: "lock.shield",
                        placeholder: "Confirmar contrasena",
                        text: $confirmPassword,
                        isSecure: true
                    )
                    .focused($focusedField, equals: .confirm)

                    if !confirmPassword.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                            Text(passwordsMatch ? "Las contrasenas coinciden" : "Las contrasenas no coinciden")
                            Spacer()
                        }
                        .font(AppTheme.captionFont)
                        .foregroundStyle(passwordsMatch ? AppTheme.success : AppTheme.error)
                        .padding(.horizontal, 4)
                    }
                }
                .padding(22)
                .editorialCard()

                HStack(alignment: .top, spacing: 10) {
                    Button {
                        acceptedTerms.toggle()
                    } label: {
                        Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(acceptedTerms ? AppTheme.primaryDark : AppTheme.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Acepto recibir ideas y recordatorios de ahorro.")
                        Text("Ver condiciones")
                            .foregroundStyle(AppTheme.primaryDark)
                    }
                }
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)

                Button {
                    signUp()
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(AppTheme.textOnPrimary)
                        }
                        Text("Comenzar mi reto")
                    }
                }
                .buttonStyle(EditorialPrimaryButtonStyle())
                .disabled(!isFormValid || isLoading)
                .opacity(isFormValid ? 1 : 0.45)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Lo que obtienes")
                        .font(AppTheme.title(20))
                        .foregroundStyle(AppTheme.textPrimary)
                    Label("Eco-score diario con explicaciones simples", systemImage: "bolt")
                    Label("Deteccion de equipos en espera y habitos de alto consumo", systemImage: "powerplug")
                    Label("Retos semanales para sumar puntos y badges", systemImage: "leaf")
                }
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
                .padding(22)
                .editorialCard(fill: AppTheme.surfaceMuted)

                HStack(spacing: 4) {
                    Text("Ya tienes cuenta?")
                        .foregroundStyle(AppTheme.textSecondary)
                    Button("Entrar") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            appState.showingSignUp = false
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

    private func signUp() {
        focusedField = nil
        isLoading = true
        appState.signUp(name: name, email: email, password: password)
        isLoading = false
    }
}

#Preview {
    SignUpView()
        .environment(AppState())
}
