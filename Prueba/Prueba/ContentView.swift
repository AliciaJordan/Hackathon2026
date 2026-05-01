import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                if appState.showingSignUp {
                    SignUpView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    LoginView()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(duration: 0.5), value: appState.isAuthenticated)
        .animation(.spring(duration: 0.4), value: appState.showingSignUp)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
