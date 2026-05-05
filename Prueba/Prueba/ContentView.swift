import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        if appState.isAuthenticated {
            MainTabView()
        } else {
            if appState.showingSignUp {
                SignUpView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
