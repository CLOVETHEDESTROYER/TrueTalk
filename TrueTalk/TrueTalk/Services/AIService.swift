import Foundation

protocol AIServiceProtocol {
    func getDatingAdvice(from input: String, persona: String) async throws -> String
    func generateAdviceResponse(for question: String, category: String) async throws -> String
    func moderateContent(_ content: String) async throws -> Bool
}

class AIService: AIServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // OpenAI API Configuration
    private let baseURL = "https://api.openai.com/v1"
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60.0
        configuration.timeoutIntervalForResource = 120.0
        
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
    
    func getDatingAdvice(from input: String, persona: String) async throws -> String {
        let prompt = buildDatingAdvicePrompt(input: input, persona: persona)
        return try await generateCompletion(prompt: prompt, maxTokens: 300)
    }
    
    func generateAdviceResponse(for question: String, category: String) async throws -> String {
        let prompt = buildAdvicePrompt(question: question, category: category)
        return try await generateCompletion(prompt: prompt, maxTokens: 400)
    }
    
    func moderateContent(_ content: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/moderations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ModerationRequest(input: content)
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AIServiceError.apiError(httpResponse.statusCode)
        }
        
        let moderationResponse = try decoder.decode(ModerationResponse.self, from: data)
        return !(moderationResponse.results.first?.flagged ?? false)
    }
    
    // MARK: - Private Methods
    
    private func generateCompletion(prompt: String, maxTokens: Int) async throws -> String {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ChatCompletionRequest(
            model: "gpt-3.5-turbo",
            messages: [
                ChatMessage(role: "system", content: "You are a helpful and empathetic dating advisor. Provide thoughtful, respectful, and practical advice while being supportive and understanding."),
                ChatMessage(role: "user", content: prompt)
            ],
            maxTokens: maxTokens,
            temperature: 0.7
        )
        
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw AIServiceError.invalidAPIKey
            } else if httpResponse.statusCode == 429 {
                throw AIServiceError.rateLimitExceeded
            } else {
                throw AIServiceError.apiError(httpResponse.statusCode)
            }
        }
        
        let completionResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
        
        guard let content = completionResponse.choices.first?.message.content else {
            throw AIServiceError.noContent
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func buildDatingAdvicePrompt(input: String, persona: String) -> String {
        return """
        You are a \(persona) giving dating advice. Please provide thoughtful, respectful advice for the following situation:
        
        "\(input)"
        
        Keep your response supportive, practical, and around 2-3 paragraphs. Focus on healthy relationship dynamics and personal growth.
        """
    }
    
    private func buildAdvicePrompt(question: String, category: String) -> String {
        return """
        Please provide thoughtful advice for this \(category) question:
        
        "\(question)"
        
        Give practical, actionable advice that's supportive and encouraging. Keep the response around 2-3 paragraphs.
        """
    }
}

// MARK: - Mock Implementation

class MockAIService: AIServiceProtocol {
    func getDatingAdvice(from input: String, persona: String) async throws -> String {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        return """
        As a \(persona), I understand that dating can be challenging. Based on your situation, here's my advice:
        
        Remember that authentic connections are built on mutual respect and genuine interest. Take time to understand yourself and what you're looking for in a partner. Don't rush the process - meaningful relationships develop naturally over time.
        
        Focus on being the best version of yourself and engaging in activities you enjoy. This will help you meet like-minded people and build confidence. Most importantly, communicate openly and honestly while respecting boundaries - both yours and your date's.
        """
    }
    
    func generateAdviceResponse(for question: String, category: String) async throws -> String {
        try await Task.sleep(nanoseconds: 1_200_000_000)
        
        return """
        Thank you for your thoughtful question about \(category). Here's some guidance:
        
        Every situation is unique, but there are some universal principles that can help. Start by taking a step back and considering all perspectives involved. Sometimes the best solution isn't immediately obvious.
        
        Consider seeking input from trusted friends or mentors who know you well. They can offer valuable insights you might not have considered. Remember, growth often comes from facing challenges with patience and self-compassion.
        """
    }
    
    func moderateContent(_ content: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Simple mock moderation - flag obviously inappropriate content
        let inappropriateKeywords = ["spam", "inappropriate", "harmful"]
        return !inappropriateKeywords.contains { content.lowercased().contains($0) }
    }
}

// MARK: - Data Models

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatCompletionResponse: Codable {
    let choices: [Choice]
    let usage: Usage?
    
    struct Choice: Codable {
        let message: ChatMessage
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

struct ModerationRequest: Codable {
    let input: String
}

struct ModerationResponse: Codable {
    let results: [ModerationResult]
    
    struct ModerationResult: Codable {
        let flagged: Bool
        let categories: [String: Bool]
        let categoryScores: [String: Double]
        
        enum CodingKeys: String, CodingKey {
            case flagged, categories
            case categoryScores = "category_scores"
        }
    }
}

// MARK: - Error Types

enum AIServiceError: Error, LocalizedError {
    case invalidAPIKey
    case invalidResponse
    case noContent
    case rateLimitExceeded
    case apiError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid OpenAI API key"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .noContent:
            return "No content received from AI service"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .apiError(let code):
            return "AI service error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
} 