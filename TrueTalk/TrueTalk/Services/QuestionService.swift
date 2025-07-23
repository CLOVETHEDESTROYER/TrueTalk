import Foundation

protocol QuestionServiceProtocol {
    func fetchQuestions() async throws -> [Question]
    func fetchQuestion(by id: String) async throws -> Question?
    func createQuestion(_ question: Question) async throws -> Question
    func updateQuestion(_ question: Question) async throws -> Question
    func deleteQuestion(id: String) async throws
    func submitResponse(_ response: QuestionResponse) async throws -> QuestionResponse
    func likeQuestion(id: String) async throws
    func unlikeQuestion(id: String) async throws
    func markResponseAsAccepted(questionId: String, responseId: String) async throws
}

class QuestionService: QuestionServiceProtocol {
    private let networkManager = NetworkManager.shared
    private let baseURL = "https://api.truetalk.com/questions"
    
    func fetchQuestions() async throws -> [Question] {
        let url = URL(string: baseURL)!
        return try await networkManager.fetch(from: url)
    }
    
    func fetchQuestion(by id: String) async throws -> Question? {
        let url = URL(string: "\(baseURL)/\(id)")!
        return try await networkManager.fetch(from: url)
    }
    
    func createQuestion(_ question: Question) async throws -> Question {
        let url = URL(string: baseURL)!
        return try await networkManager.post(question, to: url)
    }
    
    func updateQuestion(_ question: Question) async throws -> Question {
        let url = URL(string: "\(baseURL)/\(question.id)")!
        return try await networkManager.put(question, to: url)
    }
    
    func deleteQuestion(id: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)")!
        try await networkManager.delete(from: url)
    }
    
    func submitResponse(_ response: QuestionResponse) async throws -> QuestionResponse {
        let url = URL(string: "\(baseURL)/\(response.questionId)/responses")!
        return try await networkManager.post(response, to: url)
    }
    
    func likeQuestion(id: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)/like")!
        let _: EmptyBody = try await networkManager.post(EmptyBody(), to: url)
    }
    
    func unlikeQuestion(id: String) async throws {
        let url = URL(string: "\(baseURL)/\(id)/unlike")!
        let _: EmptyBody = try await networkManager.post(EmptyBody(), to: url)
    }
    
    func markResponseAsAccepted(questionId: String, responseId: String) async throws {
        let url = URL(string: "\(baseURL)/\(questionId)/responses/\(responseId)/accept")!
        let _: EmptyBody = try await networkManager.post(EmptyBody(), to: url)
    }
}

// Mock implementation for development
class MockQuestionService: QuestionServiceProtocol {
    private var questions: [Question] = [
        Question(
            content: "How do I overcome procrastination?",
            category: .personal,
            responses: [
                QuestionResponse(
                    questionId: "1",
                    content: "Try the Pomodoro Technique - work for 25 minutes, then take a 5-minute break.",
                    likes: 15
                )
            ],
            likes: 28
        )
    ]
    
    func fetchQuestions() async throws -> [Question] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return questions
    }
    
    func fetchQuestion(by id: String) async throws -> Question? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return questions.first { $0.id == id }
    }
    
    func createQuestion(_ question: Question) async throws -> Question {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        questions.append(question)
        return question
    }
    
    func updateQuestion(_ question: Question) async throws -> Question {
        try await Task.sleep(nanoseconds: 800_000_000)
        if let index = questions.firstIndex(where: { $0.id == question.id }) {
            questions[index] = question
        }
        return question
    }
    
    func deleteQuestion(id: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        questions.removeAll { $0.id == id }
    }
    
    func submitResponse(_ response: QuestionResponse) async throws -> QuestionResponse {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // TODO: Add response to the corresponding question
        return response
    }
    
    func likeQuestion(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // TODO: Implement like functionality
    }
    
    func unlikeQuestion(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // TODO: Implement unlike functionality
    }
    
    func markResponseAsAccepted(questionId: String, responseId: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        // TODO: Implement accepted answer functionality
    }
} 