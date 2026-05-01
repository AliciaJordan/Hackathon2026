import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""
    @State private var selectedCategory = "Todo"
    
    private let categories = ["Todo", "Recientes", "Favoritos", "Archivados"]
    
    private let quickActions: [(icon: String, title: String, color: Color)] = [
        ("doc.text.fill", "Documentos", Color(hex: "1A73E8")),
        ("chart.bar.fill", "Estadisticas", Color(hex: "00B4D8")),
        ("person.2.fill", "Equipo", Color(hex: "7C3AED")),
        ("calendar", "Agenda", Color(hex: "F59E0B"))
    ]
    
    private var recentActivity: [ActivityItem] {
        [
            ActivityItem(icon: "doc.fill", title: "Reporte mensual actualizado", subtitle: "Hace 2 horas", time: "10:30", color: AppTheme.primary),
            ActivityItem(icon: "person.fill.checkmark", title: "Nuevo miembro agregado", subtitle: "Hace 4 horas", time: "08:15", color: AppTheme.success),
            ActivityItem(icon: "chart.line.uptrend.xyaxis", title: "Metricas de rendimiento", subtitle: "Ayer", time: "18:45", color: AppTheme.accent),
            ActivityItem(icon: "bell.fill", title: "Recordatorio de reunion", subtitle: "Ayer", time: "14:00", color: AppTheme.warning),
            ActivityItem(icon: "checkmark.circle.fill", title: "Tarea completada", subtitle: "Hace 2 dias", time: "09:20", color: AppTheme.success)
        ]
    }
    
    private var stats: [StatItem] {
        [
            StatItem(title: "Proyectos", value: "12", icon: "folder.fill", color: AppTheme.primary),
            StatItem(title: "Tareas", value: "48", icon: "checklist", color: AppTheme.accent),
            StatItem(title: "Equipo", value: "8", icon: "person.2.fill", color: Color(hex: "7C3AED")),
            StatItem(title: "Completado", value: "89%", icon: "chart.pie.fill", color: AppTheme.success)
        ]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        searchBar
                        statsGrid
                        quickActionsSection
                        categoryFilter
                        activityList
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hola, \(appState.currentUser?.name.components(separatedBy: " ").first ?? "Usuario") 👋")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Veamos tu progreso de hoy")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            ZStack(alignment: .topTrailing) {
                Button {} label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.primary)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.primary.opacity(0.1))
                        .clipShape(Circle())
                }
                Circle()
                    .fill(AppTheme.error)
                    .frame(width: 10, height: 10)
                    .offset(x: -2, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Search
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.textSecondary)
            TextField("Buscar proyectos, tareas...", text: $searchText)
                .font(.subheadline)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 46)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.primary.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(stats) { stat in
                HStack(spacing: 12) {
                    Image(systemName: stat.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(stat.color)
                        .frame(width: 40, height: 40)
                        .background(stat.color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(stat.value)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(stat.title)
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Acceso Rapido")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickActions, id: \.title) { action in
                        VStack(spacing: 10) {
                            Image(systemName: action.icon)
                                .font(.system(size: 22))
                                .foregroundStyle(.white)
                                .frame(width: 52, height: 52)
                                .background(
                                    LinearGradient(
                                        colors: [action.color, action.color.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: action.color.opacity(0.3), radius: 6, y: 3)
                            
                            Text(action.title)
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(width: 80)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Category Filter
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            selectedCategory = category
                        }
                    } label: {
                        Text(category)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(selectedCategory == category ? .white : AppTheme.textSecondary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category
                                ? AnyShapeStyle(AppTheme.primaryGradient)
                                : AnyShapeStyle(AppTheme.cardBackground)
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedCategory == category ? Color.clear : AppTheme.textSecondary.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Activity List
    
    private var activityList: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Actividad Reciente")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button("Ver todo") {}
                    .font(.caption)
                    .foregroundStyle(AppTheme.primary)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(recentActivity) { item in
                    HStack(spacing: 14) {
                        Image(systemName: item.icon)
                            .font(.system(size: 16))
                            .foregroundStyle(item.color)
                            .frame(width: 38, height: 38)
                            .background(item.color.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text(item.time)
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    if item.id != recentActivity.last?.id {
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    let state = AppState()
    state.currentUser = .sample
    return HomeView().environment(state)
}
