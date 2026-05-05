import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedQuickAction: HomeQuickAction?
    @State private var isShowingTutorialClass = false
    private let summaryStats: [StatItem] = [
        StatItem(title: "Consumo", value: "7 kWh", icon: "bolt.fill", color: AppTheme.primaryDark),
        StatItem(title: "Eco-score", value: "84", icon: "leaf.fill", color: AppTheme.primary),
        StatItem(title: "Ahorro acumulado", value: "$18", icon: "dollarsign.circle.fill", color: AppTheme.success),
        StatItem(title: "Standby", value: "1.8 kWh", icon: "powerplug.fill", color: AppTheme.warning)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    heroCard
                    focusAndSavingsSection
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
            .sheet(isPresented: $isShowingTutorialClass) {
                TutorialClassView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hábitat")
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

            summaryStatsGrid

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

    private var summaryStatsGrid: some View {
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
                .editorialCard(fill: AppTheme.surface)
            }
        }
    }

    private var focusAndSavingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                isShowingTutorialClass = true
            } label: {
                HStack(spacing: 16) {
                    Image("default")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                        .padding(8)
                        .background(AppTheme.surface)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Clase del Ing. Palomar")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textOnPrimary.opacity(0.82))
                            .textCase(.uppercase)
                            .tracking(1.1)

                        Text("Aprende qué es la energía")
                            .font(AppTheme.title(19))
                            .foregroundStyle(AppTheme.textOnPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(AppTheme.surface)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(AppTheme.primaryLight.opacity(0.45), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)

            Text("Quick actions")
                .font(AppTheme.title(20))
                .foregroundStyle(AppTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quickActionTile(for: .energyBill)
                quickActionTile(for: .reducedToday)
                quickActionTile(for: .saveMore)
                quickActionTile(for: .monthlyImpact)
            }
        }
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

    private func quickActionTile(for action: HomeQuickAction) -> some View {
        Button {
            selectedQuickAction = action
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: action.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(action.iconColor)
                    .frame(width: 28, height: 28)

                Spacer(minLength: 0)

                Text(action.title)
                    .font(AppTheme.title(18))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(action.subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
            .padding(18)
            .background(action.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private enum HomeQuickAction: String, Identifiable {
    case energyBill
    case reducedToday
    case saveMore
    case monthlyImpact

    var id: String { rawValue }

    var title: String {
        switch self {
        case .energyBill:
            "Recibo de energia"
        case .reducedToday:
            "Lo que redujiste"
        case .saveMore:
            "Como ahorrar mas"
        case .monthlyImpact:
            "Impacto mensual"
        }
    }

    var subtitle: String {
        switch self {
        case .energyBill:
            "Sube y revisa tu historial"
        case .reducedToday:
            "Resumen del ahorro"
        case .saveMore:
            "Consejos y horarios utiles"
        case .monthlyImpact:
            "Ahorros, CO2 y avance"
        }
    }

    var icon: String {
        switch self {
        case .energyBill:
            "doc.text.magnifyingglass"
        case .reducedToday:
            "chart.line.downtrend.xyaxis"
        case .saveMore:
            "lightbulb.max.fill"
        case .monthlyImpact:
            "chart.line.uptrend.xyaxis"
        }
    }

    var iconColor: Color {
        switch self {
        case .energyBill:
            AppTheme.primaryDark
        case .reducedToday:
            AppTheme.success
        case .saveMore:
            AppTheme.warning
        case .monthlyImpact:
            AppTheme.primary
        }
    }

    var cardFill: Color {
        switch self {
        case .energyBill:
            AppTheme.surface
        case .reducedToday:
            AppTheme.surfaceMuted
        case .saveMore:
            AppTheme.surface
        case .monthlyImpact:
            AppTheme.surfaceMuted
        }
    }
}

private struct QuickActionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let action: HomeQuickAction

    var body: some View {
        switch action {
        case .energyBill:
            NavigationStack {
                PDFEnergyView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Cerrar") {
                                dismiss()
                            }
                        }
                    }
            }
        case .monthlyImpact:
            NavigationStack {
                MonthlyImpactView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Cerrar") {
                                dismiss()
                            }
                        }
                    }
            }
        case .reducedToday, .saveMore:
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
    }

    private var title: String {
        switch action {
        case .energyBill:
            "Recibo de energia"
        case .reducedToday:
            "Lo que redujiste"
        case .saveMore:
            "Como ahorrar mas"
        case .monthlyImpact:
            "Impacto mensual"
        }
    }

    private var summary: String {
        switch action {
        case .energyBill:
            "Carga tus recibos, revisa el total pagado y compara tu consumo por periodo."
        case .reducedToday:
            "Tu automatizacion nocturna ya redujo 18% del consumo en espera y evito picos de uso en la noche."
        case .saveMore:
            "Pequenos cambios en horario, aparatos y monitoreo ayudan a mantener tu consumo en escalones mas baratos."
        case .monthlyImpact:
            "Sigue tus ahorros acumulados, el CO2 evitado y el avance de tu eco-score del mes."
        }
    }

    private var cardFill: Color {
        switch action {
        case .energyBill:
            AppTheme.surface
        case .reducedToday:
            AppTheme.surface
        case .saveMore:
            AppTheme.surfaceMuted
        case .monthlyImpact:
            AppTheme.surfaceMuted
        }
    }

    private var items: [(icon: String, title: String, detail: String)] {
        switch action {
        case .energyBill:
            [
                ("doc.text.fill", "Carga PDF", "Importa tu recibo de CFE y guarda el periodo automaticamente."),
                ("pencil.line", "Corrige datos", "Edita kWh, total y periodo si el parser necesita ajustes."),
                ("chart.bar.fill", "Historial", "Compara periodos y detecta picos en tu consumo.")
            ]
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
        case .monthlyImpact:
            [
                ("leaf.fill", "CO2 evitado", "Visualiza el impacto ambiental positivo de tus cambios."),
                ("bolt.fill", "Energia ahorrada", "Consulta los kWh reducidos a lo largo del mes."),
                ("dollarsign.circle.fill", "Ahorro economico", "Relaciona tus habitos con pesos ahorrados."),
                ("chart.line.uptrend.xyaxis", "Tendencia semanal", "Compara tu progreso por semana en una sola vista.")
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
