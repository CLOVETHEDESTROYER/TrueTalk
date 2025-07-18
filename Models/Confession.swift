import Foundation

struct Confession: Identifiable, Codable, Hashable {
    let id: String
    let content: String
    let createdAt: Date
    let likes: Int
    let comments: [ConfessionComment]
    let mood: ConfessionMood
    let isReported: Bool
    
    init(
        id: String = UUID().uuidString,
        content: String,
        createdAt: Date = Date(),
        likes: Int = 0,
        comments: [ConfessionComment] = [],
        mood: ConfessionMood = .neutral,
        isReported: Bool = false
    ) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.likes = likes
        self.comments = comments
        self.mood = mood
        self.isReported = isReported
    }
}

struct ConfessionComment: Identifiable, Codable, Hashable {
    let id: String
    let confessionId: String
    let content: String
    let createdAt: Date
    let likes: Int
    
    init(
        id: String = UUID().uuidString,
        confessionId: String,
        content: String,
        createdAt: Date = Date(),
        likes: Int = 0
    ) {
        self.id = id
        self.confessionId = confessionId
        self.content = content
        self.createdAt = createdAt
        self.likes = likes
    }
}

enum ConfessionMood: String, CaseIterable, Codable {
    case happy = "happy"
    case sad = "sad"
    case angry = "angry"
    case anxious = "anxious"
    case grateful = "grateful"
    case confused = "confused"
    case excited = "excited"
    case neutral = "neutral"
    
    var displayName: String {
        switch self {
        case .happy: return "Happy"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .anxious: return "Anxious"
        case .grateful: return "Grateful"
        case .confused: return "Confused"
        case .excited: return "Excited"
        case .neutral: return "Neutral"
        }
    }
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .angry: return "😠"
        case .anxious: return "😰"
        case .grateful: return "🙏"
        case .confused: return "😕"
        case .excited: return "🎉"
        case .neutral: return "😐"
        }
    }
    
    var color: String {
        switch self {
        case .happy: return "yellow"
        case .sad: return "blue"
        case .angry: return "red"
        case .anxious: return "orange"
        case .grateful: return "green"
        case .confused: return "purple"
        case .excited: return "pink"
        case .neutral: return "gray"
        }
    }
} 