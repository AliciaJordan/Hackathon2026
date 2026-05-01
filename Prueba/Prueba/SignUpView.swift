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
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 20)
                    
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.headerGradient)
                                .frame(width: 70, height: 70)
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                        }
                        
                        Text("Crear Cuenta")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("Completa tus datos para empezar")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    // Form
                    VStack(spacing: 14) {
                        CustomTextField(
                            icon: "person.fill",
                            placeholder: "Nombre completo",
                            text: $name
                        )
                        .focused($focusedField, equals: .name)
                        .textInputAutocapitalization(.words)
                        
                        CustomTextField(
                            icon: "envelope.fill",
                            placeholder: "Correo electronico",
                            text: $email
                        )
                        .focused($focusedField, equals: .email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        
                        CustomTextField(
                            icon: "lock.fill",
                            placeholder: "Contrasena",
                            text: $password,
                            isSecure: true
                        )
                        .focused($focusedField, equals: .password)
                        
                        CustomTextField(
                            icon: "lock.shield.fill",
                            placeholder: "Confirmar contrasena",
                            text: $confirmPassword,
                            isSecure: true
                        )
                        .focused($focusedField, equals: .confirm)
                        
                        // Password match indicator
                        if !confirmPassword.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                Text(passwordsMatch ? "Las contrasenas coinciden" : "Las contrasenas no coinciden")
                                Spacer()
                            }
                            .font(.caption)
                            .foregroundStyle(passwordsMatch ? AppTheme.success : AppTheme.error)
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Terms
                    HStack(spacing: 10) {
                        Button {
                            acceptedTerms.toggle()
                        } label: {
                            Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundStyle(acceptedTerms ? AppTheme.primary : AppTheme.textSecondary)
                        }
                        
                        Text("Acepto los ")
                            .foregroundStyle(AppTheme.textSecondary) +
                        Text("Terminos y Condiciones")
                            .foregroundStyle(AppTheme.primary)
                            .underline()
                    }
                    .font(.caption)
                    .padding(.horizontal, 24)
                    
                    // Sign up button
                    Button {
                        signUp()
                    } label: {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text("Crear Cuenta")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            isFormValid
                            ? AnyShapeStyle(AppTheme.primaryGradient)
                            : AnyShapeStyle(AppTheme.textSecondary.opacity(0.3))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: isFormValid ? AppTheme.primary.opacity(0.3) : .clear, radius: 8, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .disabled(!isFormValid || isLoading)
                    
                    Spacer()
                    
                    // Back to login
                    HStack(spacing: 4) {
                        Text("Ya tienes cuenta?")
                            .foregroundStyle(AppTheme.textSecondary)
                        Button("Inicia Sesion") {
                            withAnimation(.spring(duration: 0.4)) {
                                appState.showingSignUp = false
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.primary)
                    }
                    .font(.subheadline)
                    .padding(.bottom, 32)
                }
            }
        }
    }
    
    private func signUp() {
        focusedField = nil
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            appState.signUp(name: name, email: email, password: password)
            isLoading = false
        }
    }
}

#Preview {
    SignUpView()
        .environment(AppState())
}
