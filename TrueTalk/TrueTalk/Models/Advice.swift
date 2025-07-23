import Foundation

struct Advice: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let content: String
    let authorId: String?
    let authorDisplayName: String
    let category: AdviceCategory
    let createdAt: Date
    let updatedAt: Date
    let likes: Int
    let isAnonymous: Bool
    let tags: [String]
    
    init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        authorId: String? = nil,
        authorDisplayName: String = "Anonymous",
        category: AdviceCategory = .general,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        likes: Int = 0,
        isAnonymous: Bool = true,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.authorId = authorId
        self.authorDisplayName = authorDisplayName
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.likes = likes
        self.isAnonymous = isAnonymous
        self.tags = tags
    }
}

enum AdviceCategory: String, CaseIterable, Codable {
    case general = "general"
    case relationships = "relationships"
    case career = "career"
    case health = "health"
    case education = "education"
    case finance = "finance"
    case lifestyle = "lifestyle"
    case personal = "personal"
    
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
        }
    }
    
    var icon: String {
        switch self {
        case .general: return "lightbulb"
        case .relationships: return "heart"
        case .career: return "briefcase"
        case .health: return "heart.circle"
        case .education: return "book"
        case .finance: return "dollarsign.circle"
        case .lifestyle: return "leaf"
        case .personal: return "person"
        }
    }
} 
