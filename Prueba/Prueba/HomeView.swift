import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    private let summaryStats: [StatItem] = [
        StatItem(title: "Consumo", value: "12.4 kWh", icon: "bolt.fill", color: AppTheme.primaryDark),
        StatItem(title: "Eco-score", value: "84", icon: "leaf.fill", color: AppTheme.primary),
        StatItem(title: "Ahorro", value: "$18", icon: "dollarsign.circle.fill", color: AppTheme.success),
        StatItem(title: "Standby", value: "1.8 kWh", icon: "powerplug.fill", color: AppTheme.warning)
    ]
    private let quickActions: [(icon: String, title: String, detail: String)] = [
        ("sun.max", "Evitar pico", "Mueve la lavadora a las 21:00"),
        ("battery.100.bolt", "Modo ahorro", "Baja consumo fantasma esta noche"),
        ("powerplug", "Apagar enchufes", "3 equipos siguen en espera")
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
                    dailyFocusCard
                    actionsSection
                    tipsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 110)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
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

    private var dailyFocusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Enfoque de hoy")
                    .font(AppTheme.title(20))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text("2.7 kWh evitados")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.primaryDark)
            }

            Text("Tu automatizacion nocturna ya redujo 18% del consumo en espera.")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)

            HStack(spacing: 12) {
                compactInsight(icon: "bolt.badge.clock", text: "Hora pico 18:00-21:00")
                compactInsight(icon: "powerplug", text: "3 dispositivos en espera")
            }
        }
        .padding(22)
        .editorialCard()
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Acciones recomendadas")
                .font(AppTheme.title(20))
                .foregroundStyle(AppTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickActions, id: \.title) { action in
                        VStack(alignment: .leading, spacing: 18) {
                            Image(systemName: action.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(AppTheme.primaryDark)

                            Text(action.title)
                                .font(AppTheme.title(22))
                                .foregroundStyle(AppTheme.textPrimary)

                            Text(action.detail)
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(width: 210, alignment: .leading)
                        .padding(18)
                        .editorialCard(fill: AppTheme.surface)
                    }
                }
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
}

#Preview {
    let state = AppState()
    state.currentUser = .sample
    return HomeView().environment(state)
}
