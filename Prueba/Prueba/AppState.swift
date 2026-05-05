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
        name: "Maya Rivera",
        email: "carlos@ejemplo.com",
        joinDate: Date(),
        bio: "Convirtiendo pequenos habitos en ahorro de energia real."
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
    var currentUser: User?
    var showingSignUp = false
    
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    func login(email: String, password: String) {
        withAnimation(.spring(duration: 0.5)) {
            currentUser = User(
                id: UUID(),
                name: "Maya Rivera",
                email: email,
                joinDate: Date(),
                bio: "Convirtiendo pequenos habitos en ahorro de energia real."
            )
            showingSignUp = false
        }
    }
    
    func signUp(name: String, email: String, password: String) {
        withAnimation(.spring(duration: 0.5)) {
            currentUser = User(
                id: UUID(),
                name: name,
                email: email,
                joinDate: Date(),
                bio: ""
            )
            showingSignUp = false
        }
    }
    
    func logout() {
        withAnimation(.spring(duration: 0.5)) {
            currentUser = nil
            showingSignUp = false
        }
    }
}
