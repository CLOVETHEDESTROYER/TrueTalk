import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPremiumUser = false
    @Published var defaultPersona: DatingPersona = .bestFriend
    
    // XP System
    @Published var currentXP: Int = 0
    @Published var currentLevel: Int = 1
    @Published var xpToNextLevel: Int = 100
    @Published var xpProgress: Double = 0.0
    
    // Activity Stats
    @Published var savedAdviceCount: Int = 0
    @Published var questionsAskedCount: Int = 0
    @Published var reactionsGivenCount: Int = 0
    @Published var dailyStreak: Int = 0
    
    // Badges
    @Published var earnedBadges: [UserBadge] = []
    @Published var allBadges: [UserBadge] = []
    
    private let userService = UserService()
    
    init() {
        setupBadges()
        loadUserProfile()
    }
    
    func loadUserProfile() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await fetchUserProfile()
        }
    }
    
    func selectDefaultPersona(_ persona: DatingPersona) {
        defaultPersona = persona
        
        // Save to user preferences
        Task {
            await savePersonaPreference(persona)
        }
        
        // Award badge for trying different personas
        checkPersonaExplorerBadge()
    }
    
    func editProfile() {
        // TODO: Present profile editing view
        print("Edit profile tapped")
    }
    
    func openNotificationSettings() {
        // TODO: Open notification settings
        print("Notification settings tapped")
    }
    
    func openSupport() {
        // TODO: Open support/help view
        print("Support tapped")
    }
    
    func signOut() {
        Task {
            do {
                try await userService.signOut()
                // TODO: Navigate to login/welcome screen
            } catch {
                self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
            }
        }
    }
    
    func purchasePremium() {
        // TODO: Implement actual purchase logic with StoreKit
        isPremiumUser = true
        awardBadge(badgeId: "premium_member")
        
        // Premium users get XP bonus
        addXP(50, source: "Premium Upgrade")
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - XP System
    
    func addXP(_ amount: Int, source: String) {
        let bonusMultiplier = isPremiumUser ? 2.0 : 1.0
        let finalAmount = Int(Double(amount) * bonusMultiplier)
        
        currentXP += finalAmount
        updateLevelAndProgress()
        
        // Check for level-based badges
        checkLevelBadges()
        
        print("Added \(finalAmount) XP from \(source)")
    }
    
    private func updateLevelAndProgress() {
        // Calculate level based on XP (exponential growth)
        let newLevel = Int(sqrt(Double(currentXP) / 50)) + 1
        
        if newLevel > currentLevel {
            currentLevel = newLevel
            // Award level up XP bonus
            print("Level up! Now level \(currentLevel)")
        }
        
        // Calculate XP needed for next level
        let xpForCurrentLevel = (currentLevel - 1) * (currentLevel - 1) * 50
        let xpForNextLevel = currentLevel * currentLevel * 50
        xpToNextLevel = xpForNextLevel - currentXP
        
        // Calculate progress (0.0 to 1.0)
        let xpInCurrentLevel = currentXP - xpForCurrentLevel
        let xpNeededForLevel = xpForNextLevel - xpForCurrentLevel
        xpProgress = Double(xpInCurrentLevel) / Double(xpNeededForLevel)
    }
    
    // MARK: - Badge System
    
    private func setupBadges() {
        allBadges = [
            UserBadge(
                id: "first_question",
                name: "Curious Cat",
                emoji: "🐱",
                description: "Asked your first question",
                requirement: "Ask 1 question"
            ),
            UserBadge(
                id: "ghostbuster",
                name: "Ghostbuster",
                emoji: "👻",
                description: "Called out dating red flags",
                requirement: "Save 5 No-BS Sis advice"
            ),
            UserBadge(
                id: "queen_energy",
                name: "Queen Energy",
                emoji: "👑",
                description: "Radiating confidence and self-worth",
                requirement: "Reach Level 5"
            ),
            UserBadge(
                id: "advice_collector",
                name: "Wisdom Seeker",
                emoji: "📚",
                description: "Collected lots of advice",
                requirement: "Save 25 advice cards"
            ),
            UserBadge(
                id: "streak_master",
                name: "Consistency Queen",
                emoji: "🔥",
                description: "Maintained a daily streak",
                requirement: "7-day login streak"
            ),
            UserBadge(
                id: "persona_explorer",
                name: "Open Minded",
                emoji: "🧠",
                description: "Tried different AI personas",
                requirement: "Use all 3 personas"
            ),
            UserBadge(
                id: "premium_member",
                name: "VIP Member",
                emoji: "💎",
                description: "Upgraded to Premium",
                requirement: "Purchase Premium"
            ),
            UserBadge(
                id: "level_master",
                name: "XP Legend",
                emoji: "⭐",
                description: "Reached a high level",
                requirement: "Reach Level 10"
            ),
            UserBadge(
                id: "social_butterfly",
                name: "Social Butterfly",
                emoji: "🦋",
                description: "Very active in reactions",
                requirement: "Give 100 reactions"
            )
        ]
    }
    
    private func awardBadge(badgeId: String) {
        guard let badge = allBadges.first(where: { $0.id == badgeId }),
              !earnedBadges.contains(where: { $0.id == badgeId }) else { return }
        
        earnedBadges.append(badge)
        addXP(25, source: "Badge Earned: \(badge.name)")
        
        // Show badge earned notification (TODO: implement)
        print("🎉 Badge earned: \(badge.name)")
    }
    
    private func checkLevelBadges() {
        if currentLevel >= 5 && !earnedBadges.contains(where: { $0.id == "queen_energy" }) {
            awardBadge(badgeId: "queen_energy")
        }
        
        if currentLevel >= 10 && !earnedBadges.contains(where: { $0.id == "level_master" }) {
            awardBadge(badgeId: "level_master")
        }
    }
    
    private func checkPersonaExplorerBadge() {
        // TODO: Track which personas have been used
        // For now, award after changing persona a few times
    }
    
    func checkAdviceCollectorBadge() {
        if savedAdviceCount >= 25 && !earnedBadges.contains(where: { $0.id == "advice_collector" }) {
            awardBadge(badgeId: "advice_collector")
        }
    }
    
    func checkStreakBadge() {
        if dailyStreak >= 7 && !earnedBadges.contains(where: { $0.id == "streak_master" }) {
            awardBadge(badgeId: "streak_master")
        }
    }
    
    func checkSocialButterflyBadge() {
        if reactionsGivenCount >= 100 && !earnedBadges.contains(where: { $0.id == "social_butterfly" }) {
            awardBadge(badgeId: "social_butterfly")
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchUserProfile() async {
        do {
            let fetchedUser = try await userService.fetchCurrentUser()
            self.user = fetchedUser
            
            // Load user stats and XP
            await loadUserStats()
            
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    private func loadUserStats() async {
        // Simulate loading user activity stats
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock data - in real app, this would come from the backend
        self.savedAdviceCount = Int.random(in: 5...30)
        self.questionsAskedCount = Int.random(in: 2...15)
        self.reactionsGivenCount = Int.random(in: 10...80)
        self.dailyStreak = Int.random(in: 1...14)
        
        // Calculate XP based on activities
        let baseXP = (savedAdviceCount * 5) + 
                    (questionsAskedCount * 10) + 
                    (reactionsGivenCount * 2) + 
                    (dailyStreak * 20)
        
        self.currentXP = baseXP
        updateLevelAndProgress()
        
        // Award initial badges based on activity
        checkInitialBadges()
    }
    
    private func checkInitialBadges() {
        if questionsAskedCount >= 1 {
            awardBadge(badgeId: "first_question")
        }
        
        checkAdviceCollectorBadge()
        checkStreakBadge()
        checkSocialButterflyBadge()
        checkLevelBadges()
    }
    
    private func savePersonaPreference(_ persona: DatingPersona) async {
        // TODO: Save to backend/UserDefaults
        print("Saved default persona: \(persona.displayName)")
    }
}

// MARK: - Supporting Types

struct UserBadge: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    let requirement: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UserBadge, rhs: UserBadge) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data Extensions

extension ProfileViewModel {
    static func createMockViewModel() -> ProfileViewModel {
        let viewModel = ProfileViewModel()
        
        // Mock premium user
        viewModel.isPremiumUser = true
        viewModel.currentXP = 350
        viewModel.currentLevel = 4
        viewModel.savedAdviceCount = 18
        viewModel.questionsAskedCount = 7
        viewModel.reactionsGivenCount = 45
        viewModel.dailyStreak = 12
        
        // Mock earned badges
        viewModel.earnedBadges = [
            viewModel.allBadges[0], // first_question
            viewModel.allBadges[4], // streak_master
            viewModel.allBadges[6]  // premium_member
        ]
        
        viewModel.updateLevelAndProgress()
        
        return viewModel
    }
} 