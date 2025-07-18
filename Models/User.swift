import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var displayName: String
    var bio: String
    var email: String?
    var profileImageURL: String?
    var isPrivate: Bool
    var notificationsEnabled: Bool
    let joinDate: Date
    var lastActiveDate: Date
    var reputation: Int
    var totalAdvicesGiven: Int
    var totalQuestionsAsked: Int
    var totalConfessions: Int
    
    init(
        id: String = UUID().uuidString,
        displayName: String,
        bio: String = "",
        email: String? = nil,
        profileImageURL: String? = nil,
        isPrivate: Bool = false,
        notificationsEnabled: Bool = true,
        joinDate: Date = Date(),
        lastActiveDate: Date = Date(),
        reputation: Int = 0,
        totalAdvicesGiven: Int = 0,
        totalQuestionsAsked: Int = 0,
        totalConfessions: Int = 0
    ) {
        self.id = id
        self.displayName = displayName
        self.bio = bio
        self.email = email
        self.profileImageURL = profileImageURL
        self.isPrivate = isPrivate
        self.notificationsEnabled = notificationsEnabled
        self.joinDate = joinDate
        self.lastActiveDate = lastActiveDate
        self.reputation = reputation
        self.totalAdvicesGiven = totalAdvicesGiven
        self.totalQuestionsAsked = totalQuestionsAsked
        self.totalConfessions = totalConfessions
    }
}

struct UserStats: Codable, Hashable {
    let totalAdvicesGiven: Int
    let totalQuestionsAsked: Int
    let totalConfessions: Int
    let reputation: Int
    let likesReceived: Int
    let helpfulAnswers: Int
    
    init(
        totalAdvicesGiven: Int = 0,
        totalQuestionsAsked: Int = 0,
        totalConfessions: Int = 0,
        reputation: Int = 0,
        likesReceived: Int = 0,
        helpfulAnswers: Int = 0
    ) {
        self.totalAdvicesGiven = totalAdvicesGiven
        self.totalQuestionsAsked = totalQuestionsAsked
        self.totalConfessions = totalConfessions
        self.reputation = reputation
        self.likesReceived = likesReceived
        self.helpfulAnswers = helpfulAnswers
    }
} 