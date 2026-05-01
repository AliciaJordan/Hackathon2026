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
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)
                    
                    // Logo area
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.headerGradient)
                                .frame(width: 80, height: 80)
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.white)
                        }
                        
                        Text("Bienvenido")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text("Inicia sesion para continuar")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    // Form
                    VStack(spacing: 16) {
                        CustomTextField(
                            icon: "envelope.fill",
                            placeholder: "Correo electronico",
                            text: $email,
                            isSecure: false
                        )
                        .focused($focusedField, equals: .email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        
                        CustomTextField(
                            icon: "lock.fill",
                            placeholder: "Contrasena",
                            text: $password,
                            isSecure: !isPasswordVisible,
                            trailingIcon: isPasswordVisible ? "eye.slash.fill" : "eye.fill",
                            trailingAction: { isPasswordVisible.toggle() }
                        )
                        .focused($focusedField, equals: .password)
                        
                        HStack {
                            Spacer()
                            Button("Olvidaste tu contrasena?") {}
                                .font(.caption)
                                .foregroundStyle(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .offset(x: shakeOffset)
                    
                    // Login button
                    Button {
                        login()
                    } label: {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text("Iniciar Sesion")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .disabled(isLoading)
                    
                    // Divider
                    HStack {
                        Rectangle().fill(AppTheme.textSecondary.opacity(0.3)).frame(height: 1)
                        Text("o continua con")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                        Rectangle().fill(AppTheme.textSecondary.opacity(0.3)).frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    
                    // Social buttons
                    HStack(spacing: 16) {
                        SocialButton(icon: "apple.logo", label: "Apple")
                        SocialButton(icon: "globe", label: "Google")
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Sign up link
                    HStack(spacing: 4) {
                        Text("No tienes cuenta?")
                            .foregroundStyle(AppTheme.textSecondary)
                        Button("Registrate") {
                            withAnimation(.spring(duration: 0.4)) {
                                appState.showingSignUp = true
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            appState.login(email: email, password: password)
            isLoading = false
        }
    }
}

// MARK: - Reusable Components

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
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.primary)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            if let trailingIcon, let trailingAction {
                Button(action: trailingAction) {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.primary.opacity(0.15), lineWidth: 1)
        )
    }
}

struct SocialButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        Button {} label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.textSecondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
