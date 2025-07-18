import Foundation

protocol ConfessionServiceProtocol {
    func fetchConfessions() async throws -> [Confession]
    func fetchConfession(by id: String) async throws -> Confession?
    func createConfession(_ confession: Confession) async throws -> Confession
    func deleteConfession(id: String) async throws
    func likeConfession(id: String) async throws
    func unlikeConfession(id: String) async throws
    func addComment(_ comment: ConfessionComment) async throws -> ConfessionComment
    func reportConfession(id: String, reason: String) async throws
}

class ConfessionService: ConfessionServiceProtocol {
    private let networkManager = NetworkManager.shared
    private let baseURL = "https://api.truetalk.com/confessions"
    
    func fetchConfessions() async throws -> [Confession] {
        let url = URL(string: baseURL)!
        return try await networkManager.fetch(from: url)
    }
    
    func fetchConfession(by id: String) async throws -> Confession? {
        let url = URL(string: "\(baseURL)/\(id)")!
        return try await networkManager.fetch(from: url)
    }
    
    func createConfession(_ confession: Confession) async throws -> Confession {
        let url = URL(string: baseURL)!
        return try await networkManager.post(confession, to: url)
    }
    
    func deleteConfession(id: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)")!
        try await networkManager.delete(from: url)
    }
    
    func likeConfession(id: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)/like")!
        try await networkManager.post(EmptyBody(), to: url)
    }
    
    func unlikeConfession(id: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)/unlike")!
        try await networkManager.post(EmptyBody(), to: url)
    }
    
    func addComment(_ comment: ConfessionComment) async throws -> ConfessionComment {
        let url = URL(string: "\(baseURL)/\(comment.confessionId)/comments")!
        return try await networkManager.post(comment, to: url)
    }
    
    func reportConfession(id: String, reason: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)/report")!
        let reportData = ["reason": reason]
        try await networkManager.post(reportData, to: url)
    }
}

// Mock implementation for development
class MockConfessionService: ConfessionServiceProtocol {
    private var confessions: [Confession] = [
        Confession(
            content: "I've been feeling overwhelmed lately, but I'm grateful for the small moments of peace I find throughout the day.",
            likes: 23,
            mood: .grateful
        ),
        Confession(
            content: "Sometimes I wonder if I'm on the right path in life. It's scary not knowing what the future holds.",
            likes: 45,
            mood: .anxious
        )
    ]
    
    func fetchConfessions() async throws -> [Confession] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return confessions.sorted { $0.createdAt > $1.createdAt }
    }
    
    func fetchConfession(by id: String) async throws -> Confession? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return confessions.first { $0.id == id }
    }
    
    func createConfession(_ confession: Confession) async throws -> Confession {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        confessions.append(confession)
        return confession
    }
    
    func deleteConfession(id: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        confessions.removeAll { $0.id == id }
    }
    
    func likeConfession(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // TODO: Implement like functionality
    }
    
    func unlikeConfession(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // TODO: Implement unlike functionality
    }
    
    func addComment(_ comment: ConfessionComment) async throws -> ConfessionComment {
        try await Task.sleep(nanoseconds: 800_000_000)
        // TODO: Add comment to the corresponding confession
        return comment
    }
    
    func reportConfession(id: String, reason: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        // TODO: Implement reporting functionality
    }
} 