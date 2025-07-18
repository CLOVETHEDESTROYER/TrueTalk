import Foundation
import SwiftUI

@MainActor
class AdviceFeedViewModel: ObservableObject {
    @Published var currentCards: [AdviceCard] = []
    @Published var savedAdvice: [AdviceCard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let adviceService = AdviceService()
    private var allCards: [AdviceCard] = []
    
    func loadAdviceCards() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await fetchAdviceCards()
        }
    }
    
    func handleSwipe(card: AdviceCard, direction: SwipeDirection) {
        switch direction {
        case .right:
            saveCard(card)
        case .left:
            dismissCard(card)
        }
        
        removeTopCard()
        
        // Load more cards if running low
        if currentCards.count < 3 {
            loadMoreCards()
        }
    }
    
    func saveCurrentCard() {
        guard let topCard = currentCards.first else { return }
        handleSwipe(card: topCard, direction: .right)
    }
    
    func dismissCurrentCard() {
        guard let topCard = currentCards.first else { return }
        handleSwipe(card: topCard, direction: .left)
    }
    
    func reactToCard(card: AdviceCard, reaction: EmojiReaction) {
        guard let index = currentCards.firstIndex(where: { $0.id == card.id }) else { return }
        
        var updatedCard = currentCards[index]
        
        // Remove previous reaction
        if let previousReaction = updatedCard.userReaction {
            updatedCard.reactions[previousReaction] = max(0, (updatedCard.reactions[previousReaction] ?? 0) - 1)
        }
        
        // Add new reaction
        if updatedCard.userReaction == reaction {
            // Remove reaction if tapping the same one
            updatedCard.userReaction = nil
        } else {
            updatedCard.userReaction = reaction
            updatedCard.reactions[reaction] = (updatedCard.reactions[reaction] ?? 0) + 1
        }
        
        currentCards[index] = updatedCard
        
        // Update in saved advice if applicable
        if let savedIndex = savedAdvice.firstIndex(where: { $0.id == card.id }) {
            savedAdvice[savedIndex] = updatedCard
        }
    }
    
    func reloadCards() {
        currentCards = allCards.shuffled()
        
        if currentCards.isEmpty {
            loadAdviceCards()
        }
    }
    
    func removeSavedAdvice(_ card: AdviceCard) {
        savedAdvice.removeAll { $0.id == card.id }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func saveCard(_ card: AdviceCard) {
        var savedCard = card
        savedCard.isSaved = true
        
        // Add to saved advice if not already saved
        if !savedAdvice.contains(where: { $0.id == card.id }) {
            savedAdvice.insert(savedCard, at: 0)
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func dismissCard(_ card: AdviceCard) {
        // Remove from saved advice if it was saved
        savedAdvice.removeAll { $0.id == card.id }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func removeTopCard() {
        if !currentCards.isEmpty {
            currentCards.removeFirst()
        }
    }
    
    private func loadMoreCards() {
        let remainingCards = allCards.filter { card in
            !currentCards.contains { $0.id == card.id }
        }
        
        let newCards = Array(remainingCards.shuffled().prefix(5))
        currentCards.append(contentsOf: newCards)
    }
    
    private func fetchAdviceCards() async {
        do {
            // For now, we'll use mock data
            // In a real app, this would fetch from the advice service
            self.allCards = createMockAdviceCards()
            self.currentCards = Array(allCards.shuffled().prefix(10))
            self.isLoading = false
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    private func createMockAdviceCards() -> [AdviceCard] {
        return [
            // Best Friend advice
            AdviceCard(
                content: "Hey babe! 💕 Remember, dating should be fun, not stressful. If someone isn't making you feel excited and happy, they're not the one. Trust your gut and don't settle for less than butterflies!",
                persona: .bestFriend
            ),
            AdviceCard(
                content: "Girl, you deserve someone who texts you back! If they're 'too busy' to respond but active on social media, that's not your person. You're worth consistent effort! 🌟",
                persona: .bestFriend
            ),
            AdviceCard(
                content: "Stop overthinking that text message! If you want to reach out, do it. Life's too short to play games. Be genuine, be yourself, and the right person will appreciate it. ✨",
                persona: .bestFriend
            ),
            
            // Therapist advice
            AdviceCard(
                content: "Consider your attachment style when dating. If you find yourself anxiously waiting for responses or becoming overly invested too quickly, this might indicate an anxious attachment pattern worth exploring.",
                persona: .therapist
            ),
            AdviceCard(
                content: "Healthy relationships require two whole individuals. Focus on your own emotional regulation and self-awareness rather than trying to 'complete' someone else or expecting them to complete you.",
                persona: .therapist
            ),
            AdviceCard(
                content: "Notice your patterns in relationships. Do you tend to attract similar personality types? Understanding these patterns can help you make more conscious choices in future partners.",
                persona: .therapist
            ),
            
            // No-BS Sis advice
            AdviceCard(
                content: "Stop making excuses for someone who doesn't prioritize you. If they wanted to, they would. Period. You're not asking for too much when you want basic respect and consistency.",
                persona: .noBSSis
            ),
            AdviceCard(
                content: "You're not someone's backup plan or convenient option. Know your worth and demand it. If someone can't see your value, show them the door. Next! 💪",
                persona: .noBSSis
            ),
            AdviceCard(
                content: "Stop trying to change people. Accept them as they are or move on. You can't love someone into being better, and you shouldn't have to convince anyone to treat you well.",
                persona: .noBSSis
            ),
            
            // More variety
            AdviceCard(
                content: "First dates should be low pressure! Coffee, a walk, or lunch are perfect. Save the fancy dinner dates for when you actually know if you like each other. Keep it simple, keep it real! ☕️",
                persona: .bestFriend
            ),
            AdviceCard(
                content: "Red flags in early dating often appear as inconsistency, disrespect for boundaries, or making you question your own perceptions. Trust these early warning signs rather than explaining them away.",
                persona: .therapist
            ),
            AdviceCard(
                content: "If someone ghosts you, consider it a favor. They just showed you exactly who they are - someone who lacks basic communication skills and emotional maturity. Bullet dodged! 🎯",
                persona: .noBSSis
            ),
            AdviceCard(
                content: "Take your time getting to know someone. There's no rush! Real connections develop naturally over time. Don't feel pressured to define things too quickly. Enjoy the journey! 🌸",
                persona: .bestFriend
            ),
            AdviceCard(
                content: "Communication styles matter significantly in relationships. Pay attention to how potential partners handle conflict, express needs, and respond to your communication attempts early on.",
                persona: .therapist
            ),
            AdviceCard(
                content: "Actions over words, always. Someone can say all the right things, but if their behavior doesn't match, believe the behavior. Don't fall for smooth talkers who can't follow through.",
                persona: .noBSSis
            )
        ]
    }
}

// MARK: - Mock Data Extensions

extension AdviceFeedViewModel {
    static func createMockViewModel() -> AdviceFeedViewModel {
        let viewModel = AdviceFeedViewModel()
        viewModel.loadAdviceCards()
        
        // Add some mock saved advice
        viewModel.savedAdvice = [
            AdviceCard(
                content: "Remember, you deserve someone who chooses you every day. Don't settle for someone who makes you feel like an option! 💖",
                persona: .bestFriend
            ),
            AdviceCard(
                content: "Healthy boundaries are not walls; they're gates with locks. You decide who gets access and when. Protect your energy and emotional well-being.",
                persona: .therapist
            )
        ]
        
        return viewModel
    }
} 