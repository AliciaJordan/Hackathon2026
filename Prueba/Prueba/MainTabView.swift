import SwiftUI

struct MainTabView: View {
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)

            ConsumptionView()
                .tag(1)

            MapView()
                .tag(2)

            ProfileView()
                .tag(3)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            customTabBar
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            TabBarButton(icon: "leaf.fill", label: "Inicio", index: 0, selectedTab: $selectedTab)
            TabBarButton(icon: "bolt.fill", label: "Consumo", index: 1, selectedTab: $selectedTab)
            TabBarButton(icon: "map.fill", label: "Mapa", index: 2, selectedTab: $selectedTab)
            TabBarButton(icon: "slider.horizontal.3", label: "Perfil", index: 3, selectedTab: $selectedTab)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(alignment: .top) {
            Rectangle()
                .fill(AppTheme.primaryLight.opacity(0.35))
                .frame(height: 1)
                .offset(y: -1)
        }
        .background(AppTheme.primary)
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
            withAnimation(.easeInOut(duration: 0.22)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isSelected ? AppTheme.primaryDark : AppTheme.textOnPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(AppTheme.surface)
                }
            }
            .clipShape(Capsule(style: .continuous))
        }
    }
}

#Preview {
    MainTabView(selectedTab: .constant(0))
        .environment(AppState())
}
