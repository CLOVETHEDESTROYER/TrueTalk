import Foundation
import Supabase

protocol UserServiceProtocol {
    func signUp(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func signOut() async throws
    func resetPassword(email: String) async throws
    func fetchCurrentUser() -> User?
}

class UserService: UserServiceProtocol {
    private let client = SupabaseManager.client

    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }

    func fetchCurrentUser() -> User? {
        guard let supabaseUser = client.auth.currentUser else { return nil }
        let meta = supabaseUser.userMetadata as? [String: Any] ?? [:]
        return User(
            id: supabaseUser.id.uuidString,
            displayName: meta["displayName"] as? String ?? "",
            bio: meta["bio"] as? String ?? "",
            email: supabaseUser.email,
            profileImageURL: meta["profileImageURL"] as? String,
            isPrivate: meta["isPrivate"] as? Bool ?? false,
            notificationsEnabled: meta["notificationsEnabled"] as? Bool ?? true,
            joinDate: supabaseUser.createdAt ?? Date(),
            lastActiveDate: supabaseUser.lastSignInAt ?? Date(),
            reputation: meta["reputation"] as? Int ?? 0,
            totalAdvicesGiven: meta["totalAdvicesGiven"] as? Int ?? 0,
            totalQuestionsAsked: meta["totalQuestionsAsked"] as? Int ?? 0,
            totalConfessions: meta["totalConfessions"] as? Int ?? 0
        )
    }
}

// Mock implementation for development
class MockUserService: UserServiceProtocol {
    private var currentUser: User? = User(
        displayName: "Anonymous User",
        bio: "Welcome to TrueTalk!",
        email: "user@example.com"
    )

    func signUp(email: String, password: String) async throws {}
    func signIn(email: String, password: String) async throws {}
    func signOut() async throws {}
    func resetPassword(email: String) async throws {}

    func fetchCurrentUser() -> User? {
        return currentUser
    }
} 