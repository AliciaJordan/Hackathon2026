import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if appState.isAuthenticated {
                ZStack {
                    MainTabView(selectedTab: $selectedTab)

                    if !hasSeenTutorial {
                        TutorialTourView(selectedTab: $selectedTab) {
                            hasSeenTutorial = true
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: hasSeenTutorial)
            } else {
                if appState.showingSignUp {
                    SignUpView()
                } else {
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
