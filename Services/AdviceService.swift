import Foundation

protocol AdviceServiceProtocol {
    func fetchAdvices() async throws -> [Advice]
    func fetchAdvice(by id: String) async throws -> Advice?
    func createAdvice(_ advice: Advice) async throws -> Advice
    func updateAdvice(_ advice: Advice) async throws -> Advice
    func deleteAdvice(id: String) async throws
    func likeAdvice(id: String) async throws
    func unlikeAdvice(id: String) async throws
    func searchAdvices(query: String, category: AdviceCategory?) async throws -> [Advice]
}

class AdviceService: AdviceServiceProtocol {
    private let networkManager = NetworkManager.shared
    private let baseURL = "https://api.truetalk.com/advice"
    
    func fetchAdvices() async throws -> [Advice] {
        let url = URL(string: baseURL)!
        return try await networkManager.fetch(from: url)
    }
    
    func fetchAdvice(by id: String) async throws -> Advice? {
        let url = URL(string: "\(baseURL)/\(id)")!
        return try await networkManager.fetch(from: url)
    }
    
    func createAdvice(_ advice: Advice) async throws -> Advice {
        let url = URL(string: baseURL)!
        return try await networkManager.post(advice, to: url)
    }
    
    func updateAdvice(_ advice: Advice) async throws -> Advice {
        let url = URL(string: "\(baseURL)/\(advice.id)")!
        return try await networkManager.put(advice, to: url)
    }
    
    func deleteAdvice(id: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)")!
        try await networkManager.delete(from: url)
    }
    
    func likeAdvice(id: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)/like")!
        try await networkManager.post(EmptyBody(), to: url)
    }
    
    func unlikeAdvice(id: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)/unlike")!
        try await networkManager.post(EmptyBody(), to: url)
    }
    
    func searchAdvices(query: String, category: AdviceCategory?) async throws -> [Advice] {
        var components = URLComponents(string: "\(baseURL)/search")!
        var queryItems = [URLQueryItem(name: "q", value: query)]
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category.rawValue))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        return try await networkManager.fetch(from: url)
    }
}

// Mock implementation for development
class MockAdviceService: AdviceServiceProtocol {
    private var advices: [Advice] = [
        Advice(
            title: "How to Stay Motivated",
            content: "Setting small, achievable goals can help maintain motivation over time. Celebrate small wins!",
            category: .personal,
            likes: 42
        ),
        Advice(
            title: "Career Transition Tips",
            content: "Research thoroughly, network actively, and don't be afraid to take calculated risks.",
            category: .career,
            likes: 38
        )
    ]
    
    func fetchAdvices() async throws -> [Advice] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        return advices
    }
    
    func fetchAdvice(by id: String) async throws -> Advice? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return advices.first { $0.id == id }
    }
    
    func createAdvice(_ advice: Advice) async throws -> Advice {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        advices.append(advice)
        return advice
    }
    
    func updateAdvice(_ advice: Advice) async throws -> Advice {
        try await Task.sleep(nanoseconds: 800_000_000)
        if let index = advices.firstIndex(where: { $0.id == advice.id }) {
            advices[index] = advice
        }
        return advice
    }
    
    func deleteAdvice(id: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        advices.removeAll { $0.id == id }
    }
    
    func likeAdvice(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // TODO: Implement like functionality
    }
    
    func unlikeAdvice(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // TODO: Implement unlike functionality
    }
    
    func searchAdvices(query: String, category: AdviceCategory?) async throws -> [Advice] {
        try await Task.sleep(nanoseconds: 600_000_000)
        return advices.filter { advice in
            let matchesQuery = advice.title.localizedCaseInsensitiveContains(query) ||
                             advice.content.localizedCaseInsensitiveContains(query)
            let matchesCategory = category == nil || advice.category == category
            return matchesQuery && matchesCategory
        }
    }
} 