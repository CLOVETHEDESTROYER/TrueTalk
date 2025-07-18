import Foundation

struct Question: Identifiable, Codable, Hashable {
    let id: String
    let content: String
    let authorId: String?
    let authorDisplayName: String
    let category: QuestionCategory
    let createdAt: Date
    let isAnonymous: Bool
    let responses: [QuestionResponse]
    let likes: Int
    let isResolved: Bool
    
    init(
        id: String = UUID().uuidString,
        content: String,
        authorId: String? = nil,
        authorDisplayName: String = "Anonymous",
        category: QuestionCategory = .general,
        createdAt: Date = Date(),
        isAnonymous: Bool = true,
        responses: [QuestionResponse] = [],
        likes: Int = 0,
        isResolved: Bool = false
    ) {
        self.id = id
        self.content = content
        self.authorId = authorId
        self.authorDisplayName = authorDisplayName
        self.category = category
        self.createdAt = createdAt
        self.isAnonymous = isAnonymous
        self.responses = responses
        self.likes = likes
        self.isResolved = isResolved
    }
}

struct QuestionResponse: Identifiable, Codable, Hashable {
    let id: String
    let questionId: String
    let content: String
    let authorId: String?
    let authorDisplayName: String
    let createdAt: Date
    let isAnonymous: Bool
    let likes: Int
    let isAcceptedAnswer: Bool
    
    init(
        id: String = UUID().uuidString,
        questionId: String,
        content: String,
        authorId: String? = nil,
        authorDisplayName: String = "Anonymous",
        createdAt: Date = Date(),
        isAnonymous: Bool = true,
        likes: Int = 0,
        isAcceptedAnswer: Bool = false
    ) {
        self.id = id
        self.questionId = questionId
        self.content = content
        self.authorId = authorId
        self.authorDisplayName = authorDisplayName
        self.createdAt = createdAt
        self.isAnonymous = isAnonymous
        self.likes = likes
        self.isAcceptedAnswer = isAcceptedAnswer
    }
}

enum QuestionCategory: String, CaseIterable, Codable {
    case general = "general"
    case relationships = "relationships"
    case career = "career"
    case health = "health"
    case education = "education"
    case finance = "finance"
    case lifestyle = "lifestyle"
    case personal = "personal"
    case technology = "technology"
    
    var displayName: String {
        switch self {
        case .general: return "General"
        case .relationships: return "Relationships"
        case .career: return "Career"
        case .health: return "Health"
        case .education: return "Education"
        case .finance: return "Finance"
        case .lifestyle: return "Lifestyle"
        case .personal: return "Personal"
        case .technology: return "Technology"
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "questionmark.circle"
        case .relationships: return "heart"
        case .career: return "briefcase"
        case .health: return "heart.circle"
        case .education: return "book"
        case .finance: return "dollarsign.circle"
        case .lifestyle: return "leaf"
        case .personal: return "person"
        case .technology: return "laptopcomputer"
        }
    }
} 