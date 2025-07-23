import Foundation
import SwiftUI
import UIKit

// This file now serves as the ViewModel for the dating advice focused AskView
// The previous general Q&A functionality has been moved to focus on personalized dating advice

@MainActor
class DatingAdviceViewModel: ObservableObject {
    @Published var selectedPersona: DatingPersona = .bestFriend
    @Published var userInput = ""
    @Published var advice: DatingAdvice?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var adviceHistory: [DatingAdvice] = []
    
    private let aiService = AIService(apiKey: "your-openai-api-key") // TODO: Move to secure storage
    
    var canSubmit: Bool {
        !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        userInput.count <= 500 &&
        !isLoading
    }
    
    func getAdvice() async {
        guard canSubmit else { return }
        
        isLoading = true
        errorMessage = nil
        
        let input = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let persona = selectedPersona.displayName
        
        do {
            let adviceContent = try await aiService.getDatingAdvice(from: input, persona: persona)
            
            let newAdvice = DatingAdvice(
                content: adviceContent,
                persona: selectedPersona
            )
            
            self.advice = newAdvice
            self.adviceHistory.insert(newAdvice, at: 0)
            self.isLoading = false
            
        } catch {
            self.errorMessage = "Failed to get advice: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func likeAdvice(_ advice: DatingAdvice) {
        // Update current advice
        if let currentAdvice = self.advice, currentAdvice.id == advice.id {
            var updatedAdvice = currentAdvice
            updatedAdvice.isLiked.toggle()
            updatedAdvice.likes += updatedAdvice.isLiked ? 1 : -1
            self.advice = updatedAdvice
        }
        
        // Update in history
        if let index = adviceHistory.firstIndex(where: { $0.id == advice.id }) {
            var updatedAdvice = adviceHistory[index]
            updatedAdvice.isLiked.toggle()
            updatedAdvice.likes += updatedAdvice.isLiked ? 1 : -1
            adviceHistory[index] = updatedAdvice
        }
    }
    
    func shareAdvice(_ advice: DatingAdvice) {
        let shareText = """
        Dating advice from my \(advice.persona.displayName) \(advice.persona.emoji):
        
        \(advice.content)
        
        - Shared from TrueTalk
        """
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
    
    func prepareFollowUp() {
        // Append follow-up context to user input
        let followUpPrefix = "Follow-up to previous advice: "
        if !userInput.hasPrefix(followUpPrefix) {
            userInput = followUpPrefix + userInput
        }
    }
    
    func clearAdvice() {
        withAnimation(.easeInOut(duration: 0.3)) {
            advice = nil
        }
        userInput = ""
        errorMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func saveAdviceToFavorites(_ advice: DatingAdvice) {
        // TODO: Implement saving to user favorites
        // This could integrate with UserService to save favorite advice
    }
    
    func getAdviceFromHistory(id: UUID) -> DatingAdvice? {
        return adviceHistory.first { $0.id == id }
    }
}

// MARK: - Supporting Types for Dating Advice

enum DatingPersona: String, CaseIterable {
    case bestFriend = "best_friend"
    case therapist = "therapist"
    case noBSSis = "no_bs_sis"
    
    var displayName: String {
        switch self {
        case .bestFriend: return "Best Friend"
        case .therapist: return "Therapist"
        case .noBSSis: return "No-BS Sis"
        }
    }
    
    var shortName: String {
        switch self {
        case .bestFriend: return "your bestie"
        case .therapist: return "your therapist"
        case .noBSSis: return "your sis"
        }
    }
    
    var emoji: String {
        switch self {
        case .bestFriend: return "👯‍♀️"
        case .therapist: return "🧠"
        case .noBSSis: return "💪"
        }
    }
    
    var description: String {
        switch self {
        case .bestFriend:
            return "Supportive, encouraging, and always has your back. Gives warm, empathetic advice."
        case .therapist:
            return "Professional, insightful, and helps you understand deeper patterns and motivations."
        case .noBSSis:
            return "Direct, honest, and tells you exactly what you need to hear - no sugar coating."
        }
    }
    
    var promptModifier: String {
        switch self {
        case .bestFriend:
            return "as a supportive best friend who is encouraging and empathetic"
        case .therapist:
            return "as a professional therapist with psychological insights"
        case .noBSSis:
            return "as a direct, no-nonsense sister who tells it like it is"
        }
    }
}

struct DatingAdvice: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let persona: DatingPersona
    let timestamp: Date
    var isLiked: Bool = false
    var likes: Int = 0
    var isFavorited: Bool = false
    
    init(content: String, persona: DatingPersona) {
        self.content = content
        self.persona = persona
        self.timestamp = Date()
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DatingAdvice, rhs: DatingAdvice) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data for Development

extension DatingAdviceViewModel {
    static func createMockViewModel() -> DatingAdviceViewModel {
        let viewModel = DatingAdviceViewModel()
        
        viewModel.adviceHistory = [
            DatingAdvice(
                content: "Hey girl! 💕 I totally get why you're feeling nervous about dating again. It's completely normal after a long relationship! My advice? Start slow and be kind to yourself. Maybe try some casual coffee dates first - no pressure, just getting back into the swing of meeting new people. Remember, you're amazing and anyone would be lucky to get to know you!",
                persona: .bestFriend
            ),
            DatingAdvice(
                content: "From a psychological perspective, your hesitation about dating after a long-term relationship suggests healthy self-awareness. This transition period is actually an opportunity for personal growth. I'd recommend taking time to reflect on what you learned from your previous relationship and what you're genuinely looking for now. Consider what patterns you might want to change and what values are most important to you in a partner.",
                persona: .therapist
            )
        ]
        
        return viewModel
    }
} 