import SwiftUI

struct InsightsView: View {
    private let chartData: [(label: String, value: Double)] = [
        ("L", 4.8), ("M", 4.2), ("X", 3.9), ("J", 4.6), ("V", 4.1), ("S", 3.4), ("D", 3.0)
    ]
    private let habits: [ActivityItem] = [
        ActivityItem(icon: "powerplug.fill", title: "Consumo oculto detectado", subtitle: "Router secundario y consola siguen activos toda la madrugada", time: "1.1 kWh", color: AppTheme.error),
        ActivityItem(icon: "sun.max.fill", title: "Uso alto en hora pico", subtitle: "La secadora y el horno coinciden 3 veces por semana", time: "18:00", color: AppTheme.warning),
        ActivityItem(icon: "leaf.fill", title: "Habito positivo", subtitle: "La iluminacion del salon baja automaticamente al anochecer", time: "+9%", color: AppTheme.success)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Insights")
                        .font(AppTheme.display(40))
                        .foregroundStyle(AppTheme.textPrimary)

                    summaryCard
                    chartCard
                    explanationCard
                    habitsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 12) {
            metricTile(icon: "bolt.fill", title: "Media diaria", value: "4.0 kWh")
            metricTile(icon: "leaf.fill", title: "Mejor momento", value: "22:00")
            metricTile(icon: "battery.100.bolt", title: "Ahorro", value: "23%")
        }
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Consumo semanal")
                .font(AppTheme.title(22))
                .foregroundStyle(AppTheme.textPrimary)

            HStack(alignment: .bottom, spacing: 14) {
                ForEach(chartData, id: \.label) { item in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(item.value > 4.4 ? AppTheme.warning : AppTheme.primary)
                            .frame(height: max(item.value * 28, 20))
                        Text(item.label)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Text("Tu curva mejora el fin de semana porque reduces secadora, horno y climatizacion simultanea.")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(22)
        .editorialCard()
    }

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explicacion simple")
                .font(AppTheme.title(22))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Las horas pico son tramos del dia donde la demanda y el costo de la energia suelen subir. Si desplazas equipos intensivos a horas mas tranquilas, reduces gasto sin cambiar demasiado tu rutina.")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)

            Label("Sugerencia IA: programa lavadora y lavavajillas despues de las 21:00.", systemImage: "sparkles")
                .font(AppTheme.title(15))
                .foregroundStyle(AppTheme.primaryDark)
        }
        .padding(22)
        .editorialCard(fill: AppTheme.surfaceMuted)
    }

    private var habitsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Habitos de alto uso")
                .font(AppTheme.title(22))
                .foregroundStyle(AppTheme.textPrimary)

            VStack(spacing: 0) {
                ForEach(habits) { item in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: item.icon)
                            .foregroundStyle(item.color)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(AppTheme.title(16))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text(item.subtitle)
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        Text(item.time)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.vertical, 14)

                    if item.id != habits.last?.id {
                        Divider()
                            .overlay(AppTheme.border)
                            .padding(.leading, 40)
                    }
                }
            }
        }
        .padding(22)
        .editorialCard()
    }

    private func metricTile(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.primaryDark)
            Text(value)
                .font(AppTheme.title(22))
                .foregroundStyle(AppTheme.textPrimary)
            Text(title)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
        }
        .frame(maxWidth: .infinity, minHeight: 124, alignment: .topLeading)
        .padding(16)
        .editorialCard()
    }
}

#Preview {
    InsightsView()
}
