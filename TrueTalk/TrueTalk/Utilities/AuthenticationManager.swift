import Foundation
import SwiftUI
import Supabase

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isGuestMode = false
    @Published var currentUser: User?
    @Published var questionsAskedToday = 0
    @Published var lastQuestionDate: Date?
    
    private let userService = UserService()
    private let client = SupabaseManager.client
    
    init() {
        setupAuthListener()
        loadQuestionCount()
    }
    
    private func setupAuthListener() {
        Task {
            for await (event, session) in client.auth.authStateChanges {
                await MainActor.run {
                    switch event {
                    case .signedIn:
                        self.isAuthenticated = true
                        self.currentUser = self.userService.fetchCurrentUser()
                    case .signedOut:
                        self.isAuthenticated = false
                        self.currentUser = nil
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await userService.signIn(email: email, password: password)
    }
    
    func signUp(email: String, password: String, displayName: String) async throws {
        try await userService.signUp(email: email, password: password)
        // Update user metadata with display name
        try await client.auth.update(user: UserAttributes(
            data: ["displayName": AnyJSON.string(displayName)]
        ))
    }
    
    func signOut() async throws {
        try await userService.signOut()
    }
    
    func canAskQuestion() -> Bool {
        if isAuthenticated {
            return true // Unlimited questions for authenticated users
        }
        
        if !isGuestMode {
            return false // Not authenticated and not in guest mode
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastQuestionDate {
            let lastQuestionDay = calendar.startOfDay(for: lastDate)
            if calendar.isDate(lastQuestionDay, inSameDayAs: today) {
                return questionsAskedToday < 3
            } else {
                // New day, reset count
                questionsAskedToday = 0
                lastQuestionDate = Date()
                saveQuestionCount()
                return true
            }
        } else {
            // First time asking
            lastQuestionDate = Date()
            saveQuestionCount()
            return true
        }
    }
    
    func recordQuestionAsked() {
        questionsAskedToday += 1
        lastQuestionDate = Date()
        saveQuestionCount()
    }
    
    private func loadQuestionCount() {
        let defaults = UserDefaults.standard
        questionsAskedToday = defaults.integer(forKey: "questionsAskedToday")
        lastQuestionDate = defaults.object(forKey: "lastQuestionDate") as? Date
    }
    
    private func saveQuestionCount() {
        let defaults = UserDefaults.standard
        defaults.set(questionsAskedToday, forKey: "questionsAskedToday")
        defaults.set(lastQuestionDate, forKey: "lastQuestionDate")
    }
    
    func getRemainingQuestions() -> Int {
        if isAuthenticated {
            return -1 // Unlimited
        }
        if !isGuestMode {
            return 0
        }
        return max(0, 3 - questionsAskedToday)
    }
    
    func enableGuestMode() {
        isGuestMode = true
    }
} 