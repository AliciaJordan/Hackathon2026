import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedQuickAction: HomeQuickAction?
    private let summaryStats: [StatItem] = [
        StatItem(title: "Consumo", value: "12.4 kWh", icon: "bolt.fill", color: AppTheme.primaryDark),
        StatItem(title: "Eco-score", value: "84", icon: "leaf.fill", color: AppTheme.primary),
        StatItem(title: "Ahorro", value: "$18", icon: "dollarsign.circle.fill", color: AppTheme.success),
        StatItem(title: "Standby", value: "1.8 kWh", icon: "powerplug.fill", color: AppTheme.warning)
    ]
    private let tips: [ActivityItem] = [
        ActivityItem(icon: "leaf.fill", title: "Subiste 6 puntos de eco-score hoy", subtitle: "Seguiste tu horario inteligente de climatizacion", time: "+6 XP", color: AppTheme.primary),
        ActivityItem(icon: "bolt.badge.clock.fill", title: "Evita usar el horno a las 19:00", subtitle: "Ese tramo suele ser tu hora de mayor tarifa", time: "Ahorra 12%", color: AppTheme.warning),
        ActivityItem(icon: "powerplug.fill", title: "Desconecta la consola por la noche", subtitle: "Consume energia en espera durante 7 horas", time: "0.4 kWh", color: AppTheme.error)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    heroCard
                    statsGrid
                    focusAndSavingsSection
                    tipsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 110)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selectedQuickAction) { action in
                QuickActionSheet(action: action)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Habitat")
                .font(AppTheme.captionFont)
                .textCase(.uppercase)
                .tracking(2)
                .foregroundStyle(AppTheme.textSecondary)

            Text("Hola, \(appState.currentUser?.name.components(separatedBy: " ").first ?? "Usuario").")
                .font(AppTheme.display(40))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Tu energia de hoy ya puede convertirse en mejores habitos.")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
                .frame(maxWidth: 280, alignment: .leading)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Resumen energetico")
                .font(AppTheme.captionFont)
                .textCase(.uppercase)
                .tracking(1.8)
                .foregroundStyle(AppTheme.textSecondary)

            Text("Tu hogar esta consumiendo 9% menos que ayer.")
                .font(AppTheme.display(34))
                .foregroundStyle(AppTheme.textPrimary)

            HStack(spacing: 12) {
                dashboardBadge(icon: "leaf", value: "84", label: "Eco-score")
                dashboardBadge(icon: "sun.max", value: "7 dias", label: "Racha")
                dashboardBadge(icon: "battery.100.bolt", value: "320 XP", label: "Puntos")
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Meta semanal")
                        .font(AppTheme.title(15))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Text("68%")
                        .font(AppTheme.title(15))
                        .foregroundStyle(AppTheme.primaryDark)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 999, style: .continuous)
                            .fill(AppTheme.surface)
                        RoundedRectangle(cornerRadius: 999, style: .continuous)
                            .fill(AppTheme.primary)
                            .frame(width: proxy.size.width * 0.68)
                    }
                }
                .frame(height: 10)

                Text("Reducir 4 kWh de standby.")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(24)
        .editorialCard(fill: AppTheme.surfaceMuted, radius: 32)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(summaryStats) { stat in
                VStack(alignment: .leading, spacing: 18) {
                    Image(systemName: stat.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(stat.color)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.value)
                            .font(AppTheme.title(24))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(stat.title)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1.2)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
                .padding(18)
                .editorialCard()
            }
        }
    }

    private var focusAndSavingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(AppTheme.title(20))
                .foregroundStyle(AppTheme.textPrimary)

            quickActionButton(
                title: "Lo que redujiste",
                subtitle: "Ve el resumen del ahorro de hoy",
                icon: "chart.line.downtrend.xyaxis"
            ) {
                selectedQuickAction = .reducedToday
            }

            quickActionButton(
                title: "Como ahorrar mas",
                subtitle: "Abre consejos y horarios utiles",
                icon: "lightbulb.max.fill"
            ) {
                selectedQuickAction = .saveMore
            }
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Sugerencias personalizadas")
                    .font(AppTheme.title(20))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button("Ver mas") {}
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.primaryDark)
            }

            VStack(spacing: 0) {
                ForEach(tips) { item in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: item.icon)
                            .font(.system(size: 16, weight: .medium))
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
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)

                    if item.id != tips.last?.id {
                        Divider()
                            .overlay(AppTheme.border)
                            .padding(.leading, 56)
                    }
                }
            }
            .editorialCard()
        }
    }

    private func dashboardBadge(icon: String, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.primaryDark)
            Text(value)
                .font(AppTheme.title(18))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .editorialCard(fill: AppTheme.surface)
    }

    private func compactInsight(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(text)
        }
        .font(AppTheme.captionFont)
        .foregroundStyle(AppTheme.primaryDark)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.surfaceMuted)
        .clipShape(Capsule())
    }

    private func quickActionButton(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AppTheme.primaryDark)
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.title(16))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.up")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .editorialCard()
        }
        .buttonStyle(.plain)
    }
}

private enum HomeQuickAction: String, Identifiable {
    case reducedToday
    case saveMore

    var id: String { rawValue }
}

private struct QuickActionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let action: HomeQuickAction

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text(title)
                        .font(AppTheme.display(30))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(summary)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(items, id: \.title) { item in
                            detailRow(icon: item.icon, title: item.title, detail: item.detail)
                        }
                    }
                    .padding(20)
                    .editorialCard(fill: cardFill)
                }
                .padding(20)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var title: String {
        switch action {
        case .reducedToday:
            "Lo que redujiste"
        case .saveMore:
            "Como ahorrar mas"
        }
    }

    private var summary: String {
        switch action {
        case .reducedToday:
            "Tu automatizacion nocturna ya redujo 18% del consumo en espera y evito picos de uso en la noche."
        case .saveMore:
            "Pequenos cambios en horario, aparatos y monitoreo ayudan a mantener tu consumo en escalones mas baratos."
        }
    }

    private var cardFill: Color {
        switch action {
        case .reducedToday:
            AppTheme.surface
        case .saveMore:
            AppTheme.surfaceMuted
        }
    }

    private var items: [(icon: String, title: String, detail: String)] {
        switch action {
        case .reducedToday:
            [
                ("powerplug.fill", "Standby recortado", "3 dispositivos dejaron de consumir en espera."),
                ("bolt.badge.clock.fill", "Menos carga en hora pico", "Moviste consumo fuera del bloque de 16:00 a 22:00."),
                ("leaf.fill", "Ahorro acumulado", "Tu ritmo de hoy sostiene una semana 9% mas eficiente.")
            ]
        case .saveMore:
            [
                ("clock.fill", "Horarios estrategicos", "Haz lavado o planchado antes de las 10:00 AM o despues de las 11:00 PM."),
                ("chart.bar.fill", "Controla excedentes", "Mantente en basico e intermedio para evitar el escalon mas caro."),
                ("snowflake", "Refrigerador", "Alejalo del calor y revisa que el empaque cierre bien."),
                ("powerplug.fill", "Aparatos vampiro", "Desconecta cargadores, microondas, cafeteras y consolas sin uso.")
            ]
        }
    }

    private func detailRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.primaryDark)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.title(16))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(detail)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }
}

#Preview {
    let state = AppState()
    state.currentUser = .sample
    return HomeView().environment(state)
}
