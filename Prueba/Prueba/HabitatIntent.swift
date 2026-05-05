import AppIntents

struct EstadoHabitatIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Consultar estado del hábitat"
    static var description = IntentDescription("Te dice el consumo actual de tu hábitat")
    
    // Hace que Siri no abra la app
    static var openAppWhenRun: Bool = false
    
    // Permite que Siri lo sugiera
    static var isDiscoverable: Bool = true
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(
            dialog: IntentDialog("El consumo de tu hábitat es de 140 kilowatts hora. ¡Sigue así!")
        )
    }
}



struct HabitatShortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: EstadoHabitatIntent(),
                phrases: [
                    "¿Cuál es el estado de mi hábitat en \(.applicationName)",
                    "Dime el estado de mi hábitat en \(.applicationName)",
                    "Estado de mi hábitat en \(.applicationName)"
                ],
                shortTitle: "Estado del hábitat",
                systemImageName: "leaf"
            )
        ]
    }
}
