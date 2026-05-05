import SwiftUI

struct ConsumptionView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Consumo")
                        .font(AppTheme.display(42))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Espacio reservado para tu inteligencia artificial con vision.")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: 260, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 18) {
                    Image(systemName: "viewfinder.circle")
                        .font(.system(size: 54, weight: .light))
                        .foregroundStyle(AppTheme.primaryDark)

                    Text("Vista vacia")
                        .font(AppTheme.title(28))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Aqui puedes integrar analisis visual, lectura de dispositivos o una experiencia asistida por camara cuando la tengas lista.")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, minHeight: 300, alignment: .topLeading)
                .padding(24)
                .editorialCard()

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 110)
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    ConsumptionView()
}
