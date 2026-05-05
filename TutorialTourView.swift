import SwiftUI

struct TutorialTourView: View {
    @Binding var selectedTab: Int
    let onFinish: () -> Void

    @State private var currentStep = 0
    @ScaledMetric(relativeTo: .title2) private var mascotDiameter: CGFloat = 114

    private let steps: [TutorialStep] = [
        TutorialStep(
            title: "Hola, soy el Ingeniero Palomar",
            message: "Te doy un tour rapido de la app. Estoy aqui para ayudarte a ahorrar energia.",
            icon: "bird.fill",
            tabIndex: 0,
            actionTitle: "Comenzar",
            mascotImage: "default"
        ),
        TutorialStep(
            title: "Inicio",
            message: "Aqui ves tu resumen diario, meta semanal y acciones recomendadas.",
            icon: "leaf.fill",
            tabIndex: 0,
            actionTitle: "Ir a Consumo",
            mascotImage: "pointing"
        ),
        TutorialStep(
            title: "Consumo",
            message: "En esta seccion revisas habitos, picos de uso y oportunidades de ahorro.",
            icon: "bolt.fill",
            tabIndex: 1,
            actionTitle: "Ir a Mapa",
            mascotImage: "default"
        ),
        TutorialStep(
            title: "Mapa",
            message: "Aqui exploras reportes comunitarios y zonas con mayor actividad energetica.",
            icon: "map.fill",
            tabIndex: 2,
            actionTitle: "Ir a Perfil",
            mascotImage: "pointing"
        ),
        TutorialStep(
            title: "Perfil",
            message: "Aqui ajustas tu cuenta y preferencias. Tienes dudas? Preguntame, estoy para ayudarte.",
            icon: "slider.horizontal.3",
            tabIndex: 3,
            actionTitle: "Finalizar",
            mascotImage: "neck"
        ),
        TutorialStep(
            title: "Todo listo",
            message: "Excelente. Ya conoces las funciones principales de Habitat.",
            icon: "checkmark.seal.fill",
            tabIndex: 0,
            actionTitle: "Entrar a la app",
            mascotImage: "squish"
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.28)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 10) {

                        Image(steps[currentStep].mascotImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: mascotDiameter * 1.7, height: mascotDiameter * 1.7)
                    
                            .frame(width: mascotDiameter, height: mascotDiameter)
                
                    VStack(alignment: .leading, spacing: 0.02) {
                        
                        Text("Ingeniero Palomar")
                            .font(AppTheme.title(22))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("Paso \(currentStep + 1) de \(steps.count)")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textSecondary)
                        Text(steps[currentStep].title)
                            .font(AppTheme.title(22))
                            .foregroundStyle(AppTheme.primaryDark)
                    }
                     .padding(.leading, 22)

                    Spacer()

                    Image(systemName: steps[currentStep].icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppTheme.primaryDark)
                }

                Rectangle()
                    .fill(AppTheme.primaryLight)
                    .frame(height: 1)
                    .padding(.leading, 8)

                Text(steps[currentStep].message)
                    .font(AppTheme.title(19))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.leading, 8)

                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Capsule(style: .continuous)
                            .fill(index == currentStep ? AppTheme.primaryDark : AppTheme.surfaceMuted)
                            .frame(height: 7)
                    }
                }

                HStack(spacing: 10) {
                    Button("Saltar") {
                        onFinish()
                    }
                    .buttonStyle(EditorialSecondaryButtonStyle())

                    Button(steps[currentStep].actionTitle) {
                        if currentStep < steps.count - 1 {
                            currentStep += 1
                            focusCurrentStepTab()
                        } else {
                            onFinish()
                        }
                    }
                    .buttonStyle(EditorialPrimaryButtonStyle())
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
            .padding(.top, 10)
            .editorialCard()
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
        .onAppear {
            focusCurrentStepTab()
        }
    }

    private func focusCurrentStepTab() {
        withAnimation(.easeInOut(duration: 0.22)) {
            selectedTab = steps[currentStep].tabIndex
        }
    }
}

private struct TutorialStep {
    let title: String
    let message: String
    let icon: String
    let tabIndex: Int
    let actionTitle: String
    let mascotImage: String
}

#Preview {
    TutorialTourView(selectedTab: .constant(0), onFinish: {})
}
