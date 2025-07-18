import Foundation

protocol UserServiceProtocol {
    func fetchCurrentUser() async throws -> User?
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws
    func fetchUserStats(for userId: String) async throws -> UserStats
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, displayName: String) async throws -> User
    func signOut() async throws
    func resetPassword(email: String) async throws
}

class UserService: UserServiceProtocol {
    private let networkManager = NetworkManager.shared
    private let baseURL = "https://api.truetalk.com/users"
    private let authURL = "https://api.truetalk.com/auth"
    
    func fetchCurrentUser() async throws -> User? {
        let url = URL(string: "\(baseURL)/me")!
        return try await networkManager.fetch(from: url)
    }
    
    func updateUser(_ user: User) async throws -> User {
        let url = URL(string: "\(baseURL)/\(user.id)")!
        return try await networkManager.put(user, to: url)
    }
    
    func deleteUser(id: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)")!
        try await networkManager.delete(from: url)
    }
    
    func fetchUserStats(for userId: String) async throws -> UserStats {
        let url = URL(string: "\(baseURL)/\(userId)/stats")!
        return try await networkManager.fetch(from: url)
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let url = URL(string: "\(authURL)/signin")!
        let credentials = ["email": email, "password": password]
        return try await networkManager.post(credentials, to: url)
    }
    
    func signUp(email: String, password: String, displayName: String) async throws -> User {
        let url = URL(string: "\(authURL)/signup")!
        let userData = [
            "email": email,
            "password": password,
            "displayName": displayName
        ]
        return try await networkManager.post(userData, to: url)
    }
    
    func signOut() async throws {
        let url = URL(string: "\(authURL)/signout")!
        try await networkManager.post(EmptyBody(), to: url)
    }
    
    func resetPassword(email: String) async throws {
        let url = URL(string: "\(authURL)/reset-password")!
        let resetData = ["email": email]
        try await networkManager.post(resetData, to: url)
    }
}

// Mock implementation for development
class MockUserService: UserServiceProtocol {
    private var currentUser: User? = User(
        displayName: "Anonymous User",
        bio: "Welcome to TrueTalk!",
        email: "user@example.com"
    )
    
    func fetchCurrentUser() async throws -> User? {
        try await Task.sleep(nanoseconds: 500_000_000)
        return currentUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        try await Task.sleep(nanoseconds: 800_000_000)
        currentUser = user
        return user
    }
    
    func deleteUser(id: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        currentUser = nil
    }
    
    func fetchUserStats(for userId: String) async throws -> UserStats {
        try await Task.sleep(nanoseconds: 600_000_000)
        return UserStats(
            totalAdvicesGiven: 12,
            totalQuestionsAsked: 8,
            totalConfessions: 5,
            reputation: 156,
            likesReceived: 89,
            helpfulAnswers: 7
        )
    }
    
    func signIn(email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let user = User(
            displayName: "Signed In User",
            bio: "Just signed in!",
            email: email
        )
        currentUser = user
        return user
    }
    
    func signUp(email: String, password: String, displayName: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_200_000_000)
        let user = User(
            displayName: displayName,
            bio: "New to TrueTalk!",
            email: email
        )
        currentUser = user
        return user
    }
    
    func signOut() async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        currentUser = nil
    }
    
    func resetPassword(email: String) async throws {
        try await Task.sleep(nanoseconds: 800_000_000)
        // Mock password reset - in real implementation, this would send an email
    }
} 