import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var isEditing = false
    @State private var editName = ""
    @State private var editBio = ""
    @State private var showingLogoutAlert = false
    @State private var notificationsEnabled = true
    @State private var smartAlertsEnabled = true
    @State private var standbyProtection = true

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    topTitle
                    profileHeader
                    profileStats
                    preferencesSection
                    menuSections
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 110)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ProfileFeature.self) { feature in
                switch feature {
                case .sustainableHabits:
                    SustainableHabitsView()
                case .monthlyImpact:
                    MonthlyImpactView()
                case .standbyConsumption:
                    StandbyConsumptionView()
                }
            }
            .sheet(isPresented: $isEditing) {
                editProfileSheet
            }
            .alert("Cerrar Sesion", isPresented: $showingLogoutAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Cerrar Sesion", role: .destructive) {
                    appState.logout()
                }
            } message: {
                Text("Estas seguro de que quieres salir de tu panel de energia?")
            }
        }
    }

    private var topTitle: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Perfil / Control")
                .font(AppTheme.display(38))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Tu cuenta y tus automatizaciones en un solo lugar.")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(AppTheme.surfaceMuted)
                        .frame(width: 82, height: 82)

                    Text(appState.currentUser?.avatarInitials ?? "U")
                        .font(AppTheme.title(26))
                        .foregroundStyle(AppTheme.primaryDark)
                }

                Spacer()

                Button {
                    editName = appState.currentUser?.name ?? ""
                    editBio = appState.currentUser?.bio ?? ""
                    isEditing = true
                } label: {
                    Text("Editar")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.primaryDark)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppTheme.surfaceMuted)
                        .clipShape(Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(appState.currentUser?.name ?? "Usuario")
                    .font(AppTheme.title(28))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(appState.currentUser?.email ?? "")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)

                if let bio = appState.currentUser?.bio, !bio.isEmpty {
                    Text(bio)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding(24)
        .editorialCard(fill: AppTheme.surfaceMuted, radius: 30)
    }

    private var profileStats: some View {
        HStack(spacing: 0) {
            ProfileStatView(value: "320", label: "Eco-puntos")
            Divider().overlay(AppTheme.border)
            ProfileStatView(value: "7", label: "Racha")
            Divider().overlay(AppTheme.border)
            ProfileStatView(value: "5", label: "Badges")
        }
        .padding(.vertical, 14)
        .editorialCard()
    }

    private var menuSections: some View {
        VStack(spacing: 18) {
            MenuSection(title: "Resumen") {
                MenuRow(
                    icon: "leaf.fill",
                    title: "Habitos sostenibles",
                    subtitle: "Ideas diarias para consumir menos energia",
                    color: AppTheme.primary,
                    destination: .sustainableHabits
                )
                Divider().overlay(AppTheme.border).padding(.leading, 56)
                MenuRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Impacto mensual",
                    subtitle: "Ahorros, CO2 y eco-score acumulado",
                    color: AppTheme.success,
                    destination: .monthlyImpact
                )
                Divider().overlay(AppTheme.border).padding(.leading, 56)
                MenuRow(
                    icon: "battery.75",
                    title: "Reducir consumo en espera",
                    subtitle: "Control remoto de dispositivos en standby",
                    color: AppTheme.primaryDark,
                    destination: .standbyConsumption
                )
            }

            Button {
                showingLogoutAlert = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.error)
                        .frame(width: 24)

                    Text("Cerrar Sesion")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.error)

                    Spacer()
                }
                .padding(18)
            }
            .editorialCard()
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preferencias")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1.6)

            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "bell.fill",
                    title: "Notificaciones motivacionales",
                    color: AppTheme.primary,
                    isOn: $notificationsEnabled
                )
                Divider().overlay(AppTheme.border).padding(.leading, 56)
                SettingsToggleRow(
                    icon: "bolt.badge.clock.fill",
                    title: "Alertas en horas pico",
                    color: AppTheme.warning,
                    isOn: $smartAlertsEnabled
                )
                Divider().overlay(AppTheme.border).padding(.leading, 56)
                SettingsToggleRow(
                    icon: "powerplug.fill",
                    title: "Proteccion contra standby",
                    color: AppTheme.success,
                    isOn: $standbyProtection
                )
            }
            .editorialCard()
        }
    }

    private var editProfileSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                    CustomTextField(icon: "person", placeholder: "Tu nombre", text: $editName)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                    TextEditor(text: $editBio)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(height: 120)
                        .padding(12)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(AppTheme.border, lineWidth: 1)
                        }
                }

                Spacer()
            }
            .padding(24)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { isEditing = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        appState.currentUser?.name = editName
                        appState.currentUser?.bio = editBio
                        isEditing = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct ProfileStatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTheme.title(24))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
                .tracking(1.6)

            VStack(spacing: 0) {
                content
            }
            .editorialCard()
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: ProfileFeature

    var body: some View {
        NavigationLink(value: destination) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

enum ProfileFeature: Hashable {
    case sustainableHabits
    case monthlyImpact
    case standbyConsumption
}

struct SustainableHabitsView: View {
    private let routines: [HabitRoutine] = [
        .init(
            title: "Manana eficiente",
            detail: "Abre cortinas, ventila 10 minutos y evita luces por 2 horas.",
            impact: "Ahorro estimado: 0.3 kWh/dia",
            icon: "sun.max.fill",
            color: AppTheme.warning
        ),
        .init(
            title: "Lavado inteligente",
            detail: "Usa cargas completas y agua fria para reducir consumo del calentador.",
            impact: "Ahorro estimado: 0.5 kWh/dia",
            icon: "drop.fill",
            color: AppTheme.primary
        ),
        .init(
            title: "Cocina consciente",
            detail: "Tapa ollas, agrupa preparaciones y aprovecha calor residual.",
            impact: "Ahorro estimado: 0.4 kWh/dia",
            icon: "frying.pan.fill",
            color: AppTheme.success
        ),
        .init(
            title: "Climatizacion responsable",
            detail: "Mantén el AC a 24°C y usa ventilador para apoyo.",
            impact: "Ahorro estimado: 0.7 kWh/dia",
            icon: "wind",
            color: AppTheme.primaryDark
        ),
        .init(
            title: "Noche eco",
            detail: "Activa modo ahorro, desconecta cargadores y baja brillo de pantallas.",
            impact: "Ahorro estimado: 0.3 kWh/dia",
            icon: "moon.stars.fill",
            color: AppTheme.primaryLight
        ),
        .init(
            title: "Standby cero",
            detail: "Conecta TV y consola a regleta con interruptor para apagado total.",
            impact: "Ahorro estimado: 0.6 kWh/dia",
            icon: "powerplug.fill",
            color: AppTheme.success
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Habitos sostenibles")
                    .font(AppTheme.display(32))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Rutinas diarias para bajar consumo sin perder comodidad.")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)

                habitsSummaryCard

                ForEach(routines) { routine in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(AppTheme.surfaceMuted)
                                .frame(width: 38, height: 38)
                            Image(systemName: routine.icon)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(routine.color)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(routine.title)
                                .font(AppTheme.title(18))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text(routine.detail)
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.textSecondary)
                            Text(routine.impact)
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.success)
                        }
                    }
                    .padding(18)
                    .editorialCard()
                }
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Habitos")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var habitsSummaryCard: some View {
        HStack(spacing: 0) {
            summaryMetric(value: "2.8", label: "kWh/dia potencial")
            Divider().overlay(AppTheme.border)
            summaryMetric(value: "$270", label: "Ahorro/mes aprox")
            Divider().overlay(AppTheme.border)
            summaryMetric(value: "6", label: "Acciones sugeridas")
        }
        .padding(.vertical, 14)
        .editorialCard(fill: AppTheme.surfaceMuted)
    }

    private func summaryMetric(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTheme.title(20))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
    }
}

struct MonthlyImpactView: View {
    private let progressValue: CGFloat = 0.72
    private let monthlyRows: [MonthlyImpactRow] = [
        .init(period: "Semana 1", kwhSaved: 14.5, co2Kg: 5.2, pesosSaved: 48.0),
        .init(period: "Semana 2", kwhSaved: 16.2, co2Kg: 5.9, pesosSaved: 54.0),
        .init(period: "Semana 3", kwhSaved: 18.1, co2Kg: 6.5, pesosSaved: 60.0),
        .init(period: "Semana 4", kwhSaved: 19.2, co2Kg: 6.9, pesosSaved: 64.0)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Impacto mensual")
                    .font(AppTheme.display(32))
                    .foregroundStyle(AppTheme.textPrimary)

                HStack(spacing: 12) {
                    impactStat(title: "CO2 evitado", value: "24.5 kg")
                    impactStat(title: "Energia ahorrada", value: "68 kWh")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Eco-score del mes")
                        .font(AppTheme.title(18))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("720 / 1000 puntos")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.textSecondary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AppTheme.surfaceMuted)
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(AppTheme.primary)
                                .frame(width: geo.size.width * progressValue)
                        }
                    }
                    .frame(height: 14)

                    Text("Subiste +18% frente al mes pasado.")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.success)
                }
                .padding(18)
                .editorialCard()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Resumen visual")
                        .font(AppTheme.title(18))
                    HStack(alignment: .bottom, spacing: 10) {
                        chartBar(label: "S1", height: 30)
                        chartBar(label: "S2", height: 44)
                        chartBar(label: "S3", height: 56)
                        chartBar(label: "S4", height: 70)
                    }
                }
                .padding(18)
                .editorialCard()

                monthlyImpactTable
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Impacto")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func impactStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(AppTheme.title(22))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .editorialCard()
    }

    private func chartBar(label: String, height: CGFloat) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(AppTheme.primaryLight)
                .frame(width: 26, height: height)
            Text(label)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var monthlyImpactTable: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Detalle de consumo y gasto")
                .font(AppTheme.title(18))
                .foregroundStyle(AppTheme.textPrimary)

            VStack(spacing: 0) {
                tableHeader

                ForEach(monthlyRows) { row in
                    HStack(spacing: 8) {
                        Text(row.period)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: "%.1f", row.kwhSaved))
                            .frame(width: 64, alignment: .trailing)
                        Text(String(format: "%.1f", row.co2Kg))
                            .frame(width: 58, alignment: .trailing)
                        Text("$\(Int(row.pesosSaved))")
                            .frame(width: 64, alignment: .trailing)
                    }
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)

                    if row.id != monthlyRows.last?.id {
                        Divider().overlay(AppTheme.border)
                    }
                }
            }
            .editorialCard(fill: AppTheme.surfaceMuted, radius: 18)
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 8) {
            Text("Periodo")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("kWh")
                .frame(width: 64, alignment: .trailing)
            Text("CO2")
                .frame(width: 58, alignment: .trailing)
            Text("MXN")
                .frame(width: 64, alignment: .trailing)
        }
        .font(.system(size: 11, weight: .semibold, design: .default))
        .foregroundStyle(AppTheme.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.surface)
    }
}

struct StandbyConsumptionView: View {
    @State private var devices: [IoTDevice] = [
        .init(name: "TV Sala", isOn: true, standbyWatts: 8),
        .init(name: "Consola", isOn: true, standbyWatts: 12),
        .init(name: "Router Secundario", isOn: false, standbyWatts: 6),
        .init(name: "Microondas", isOn: true, standbyWatts: 4)
    ]
    private let monthlyRatePerKwh: Double = 3.25

    private var savedWatts: Int {
        devices.filter { !$0.isOn }.reduce(0) { $0 + $1.standbyWatts }
    }

    private var monthlyKWhSaved: Double {
        Double(savedWatts) * 24.0 * 30.0 / 1000.0
    }

    private var monthlyPesosSaved: Double {
        monthlyKWhSaved * monthlyRatePerKwh
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Consumo en espera")
                    .font(AppTheme.display(32))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Apaga dispositivos en standby para cortar consumo fantasma.")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Ahorro actual estimado")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("\(savedWatts) W evitados")
                        .font(AppTheme.title(24))
                        .foregroundStyle(AppTheme.success)
                    Text(String(format: "%.1f kWh/mes | $%.0f MXN/mes", monthlyKWhSaved, monthlyPesosSaved))
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(18)
                .editorialCard()

                VStack(spacing: 0) {
                    ForEach($devices) { $device in
                        HStack(spacing: 12) {
                            Image(systemName: device.isOn ? "powerplug.fill" : "powerplug")
                                .foregroundStyle(device.isOn ? AppTheme.warning : AppTheme.success)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(device.name)
                                    .font(AppTheme.bodyFont)
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("\(device.standbyWatts)W en standby")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $device.isOn)
                                .labelsHidden()
                                .tint(AppTheme.primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        if device.id != devices.last?.id {
                            Divider().overlay(AppTheme.border).padding(.leading, 56)
                        }
                    }
                }
                .editorialCard()

                standbyCostTable
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Standby")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var standbyCostTable: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tabla de consumo fantasma")
                .font(AppTheme.title(18))
                .foregroundStyle(AppTheme.textPrimary)

            VStack(spacing: 0) {
                standbyHeader

                ForEach(devices) { device in
                    HStack(spacing: 8) {
                        Text(device.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(device.isOn ? "Activo" : "Apagado")
                            .frame(width: 64, alignment: .trailing)
                            .foregroundStyle(device.isOn ? AppTheme.warning : AppTheme.success)
                        Text("\(device.standbyWatts)W")
                            .frame(width: 52, alignment: .trailing)
                        Text(String(format: "%.1f", device.standbyKwhMonth))
                            .frame(width: 52, alignment: .trailing)
                        Text("$\(Int(device.standbyPesosMonth(ratePerKwh: monthlyRatePerKwh)))")
                            .frame(width: 56, alignment: .trailing)
                    }
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)

                    if device.id != devices.last?.id {
                        Divider().overlay(AppTheme.border)
                    }
                }
            }
            .editorialCard(fill: AppTheme.surfaceMuted, radius: 18)
        }
    }

    private var standbyHeader: some View {
        HStack(spacing: 8) {
            Text("Dispositivo")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Estado")
                .frame(width: 64, alignment: .trailing)
            Text("W")
                .frame(width: 52, alignment: .trailing)
            Text("kWh")
                .frame(width: 52, alignment: .trailing)
            Text("MXN")
                .frame(width: 56, alignment: .trailing)
        }
        .font(.system(size: 11, weight: .semibold, design: .default))
        .foregroundStyle(AppTheme.textSecondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.surface)
    }
}

struct HabitRoutine: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let impact: String
    let icon: String
    let color: Color
}

struct IoTDevice: Identifiable {
    let id = UUID()
    let name: String
    var isOn: Bool
    let standbyWatts: Int

    var standbyKwhMonth: Double {
        Double(standbyWatts) * 24.0 * 30.0 / 1000.0
    }

    func standbyPesosMonth(ratePerKwh: Double) -> Double {
        standbyKwhMonth * ratePerKwh
    }
}

struct MonthlyImpactRow: Identifiable {
    let id = UUID()
    let period: String
    let kwhSaved: Double
    let co2Kg: Double
    let pesosSaved: Double
}

#Preview {
    let state = AppState()
    state.currentUser = .sample
    return ProfileView().environment(state)
}
