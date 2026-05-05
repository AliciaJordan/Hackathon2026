import SwiftUI

struct AutomationView: View {
    @State private var livingRoomOn = true
    @State private var chargerOn = false
    @State private var awayMode = true
    @State private var sleepSchedule = true

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    Text("Automation")
                        .font(AppTheme.display(40))
                        .foregroundStyle(AppTheme.textPrimary)

                    controlCard
                    scheduleCard
                    recommendationsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var controlCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Control remoto")
                .font(AppTheme.title(22))
                .foregroundStyle(AppTheme.textPrimary)
            ToggleRow(title: "Sala principal", subtitle: "Luces y TV", icon: "lightbulb.max.fill", isOn: $livingRoomOn)
            ToggleRow(title: "Cargadores", subtitle: "Corte nocturno", icon: "powerplug.fill", isOn: $chargerOn)
            ToggleRow(title: "Modo fuera de casa", subtitle: "Reduce cargas pasivas", icon: "house.and.flag.fill", isOn: $awayMode)
        }
        .padding(22)
        .editorialCard()
    }

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Horarios automaticos")
                    .font(AppTheme.title(22))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Toggle("", isOn: $sleepSchedule)
                    .labelsHidden()
                    .tint(AppTheme.primary)
            }
            VStack(alignment: .leading, spacing: 10) {
                Label("22:30 Apagado de enchufes en standby", systemImage: "moon.stars")
                Label("07:00 Reactivacion gradual de cocina y climatizacion", systemImage: "sunrise")
                Label("18:00 Recordatorio para evitar secadora y horno simultaneos", systemImage: "bell")
            }
            .font(AppTheme.bodyFont)
            .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(22)
        .editorialCard(fill: AppTheme.surfaceMuted)
    }

    private var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Sugerencias IA")
                .font(AppTheme.title(22))
                .foregroundStyle(AppTheme.textPrimary)
            recommendation(title: "Reduce standby usage", subtitle: "Apaga automaticamente la zona de entretenimiento si no hay actividad durante 90 minutos.")
            recommendation(title: "Avoid peak hours", subtitle: "Desplaza el lavado a las 21:15 para mantener tu eco-score por encima de 80.")
            recommendation(title: "Turn off unused devices", subtitle: "El cargador del estudio sigue conectado aun cuando la bateria esta completa.")
        }
        .padding(22)
        .editorialCard()
    }

    private func recommendation(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTheme.title(16))
                .foregroundStyle(AppTheme.textPrimary)
            Text(subtitle)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct ToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.primaryDark)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.title(16))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppTheme.primary)
        }
    }
}

#Preview {
    AutomationView()
}
