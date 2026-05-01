import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                Text("") // Placeholder for Explore
                    .tag(1)
                
                Text("") // Placeholder for Add
                    .tag(2)
                
                ProfileView()
                    .tag(3)
                
                SettingsView()
                    .tag(4)
            }
            
            // Custom Tab Bar
            customTabBar
        }
    }
    
    private var customTabBar: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TabBarButton(icon: "house.fill", label: "Inicio", index: 0, selectedTab: $selectedTab)
                    TabBarButton(icon: "magnifyingglass", label: "Explorar", index: 1, selectedTab: $selectedTab)

                    // Center add button
                    Button {
                        // Add action
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primaryGradient)
                                .frame(width: 52, height: 52)
                                .shadow(color: AppTheme.primary.opacity(0.3), radius: 10, y: 4)

                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .offset(y: -10)
                    }
                    .frame(maxWidth: .infinity)

                    TabBarButton(icon: "person.fill", label: "Perfil", index: 3, selectedTab: $selectedTab)
                    TabBarButton(icon: "gearshape.fill", label: "Ajustes", index: 4, selectedTab: $selectedTab)
                }
                .padding(.horizontal, 8)
                .padding(.top, 10)
                .padding(.bottom, geo.safeAreaInsets.bottom > 0 ? geo.safeAreaInsets.bottom : 12)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .background(alignment: .bottom) {
                AppTheme.cardBackground
                    .frame(height: 80 + geo.safeAreaInsets.bottom)
                    .shadow(color: AppTheme.primary.opacity(0.08), radius: 16, y: -6)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let index: Int
    @Binding var selectedTab: Int
    
    private var isSelected: Bool { selectedTab == index }
    
    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .symbolEffect(.bounce, value: isSelected)
                
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.textSecondary.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
