import SwiftUI

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var avatarInitials: String {
        let parts = name.split(separator: " ")
        let initials = parts.prefix(2).compactMap { $0.first }.map { String($0) }
        return initials.joined().uppercased()
    }
    var joinDate: Date
    var bio: String
    
    static let sample = User(
        id: UUID(),
        name: "Carlos Rivera",
        email: "carlos@ejemplo.com",
        joinDate: Date(),
        bio: "Desarrollador iOS apasionado por el diseno limpio."
    )
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color
}

struct StatItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

@Observable
class AppState {
    var isAuthenticated = false
    var currentUser: User?
    var showingSignUp = false
    
    func login(email: String, password: String) {
        currentUser = User(
            id: UUID(),
            name: "Carlos Rivera",
            email: email,
            joinDate: Date(),
            bio: "Desarrollador iOS apasionado por el diseno limpio."
        )
        withAnimation(.spring(duration: 0.5)) {
            isAuthenticated = true
        }
    }
    
    func signUp(name: String, email: String, password: String) {
        currentUser = User(
            id: UUID(),
            name: name,
            email: email,
            joinDate: Date(),
            bio: ""
        )
        withAnimation(.spring(duration: 0.5)) {
            isAuthenticated = true
        }
    }
    
    func logout() {
        withAnimation(.spring(duration: 0.5)) {
            isAuthenticated = false
            currentUser = nil
        }
    }
}
