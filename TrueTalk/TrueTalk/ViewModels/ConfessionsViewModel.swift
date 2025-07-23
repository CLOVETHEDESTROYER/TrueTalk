import Foundation
import SwiftUI
import UIKit

@MainActor
class ConfessionsViewModel: ObservableObject {
    @Published var confessions: [Confession] = []
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let confessionService = ConfessionService()
    
    func loadConfessions() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await fetchConfessions()
        }
    }
    
    func refreshConfessions() async {
        await fetchConfessions()
    }
    
    func submitConfession(_ confession: Confession) async {
        isSubmitting = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let submittedConfession = try await confessionService.createConfession(confession)
            
            // Add to local list at the beginning
            self.confessions.insert(submittedConfession, at: 0)
            
            self.successMessage = "Your story has been shared anonymously ✨"
            self.isSubmitting = false
            
            // Auto-clear success message
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.successMessage = nil
            }
            
        } catch {
            self.errorMessage = "Failed to share your story: \(error.localizedDescription)"
            self.isSubmitting = false
        }
    }
    
    func reactToConfession(confession: Confession, reaction: ConfessionReaction) {
        guard let index = confessions.firstIndex(where: { $0.id == confession.id }) else { return }
        
        var updatedConfession = confessions[index]
        
        // Remove previous reaction if any
        if let previousReaction = updatedConfession.userReaction {
            let currentCount = updatedConfession.reactions[previousReaction] ?? 0
            updatedConfession.reactions[previousReaction] = max(0, currentCount - 1)
        }
        
        // Add new reaction or remove if tapping the same one
        if updatedConfession.userReaction == reaction {
            // Remove reaction if tapping the same one
            updatedConfession.userReaction = nil
        } else {
            // Add new reaction
            updatedConfession.userReaction = reaction
            let currentCount = updatedConfession.reactions[reaction] ?? 0
            updatedConfession.reactions[reaction] = currentCount + 1
        }
        
        // Update the confession in the array
        confessions[index] = updatedConfession
        
        // Send reaction to backend
        Task {
            await sendReactionToBackend(confessionId: confession.id, reaction: reaction)
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    private func fetchConfessions() async {
        do {
            let fetchedConfessions = try await confessionService.fetchConfessions()
            self.confessions = fetchedConfessions.sorted { $0.createdAt > $1.createdAt }
            self.isLoading = false
            
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    private func sendReactionToBackend(confessionId: String, reaction: ConfessionReaction) async {
        do {
            // TODO: Implement actual backend reaction submission
            // For now, just simulate the API call
            try await Task.sleep(nanoseconds: 200_000_000)
            print("Sent reaction \(reaction.emoji) for confession \(confessionId)")
            
        } catch {
            print("Failed to send reaction: \(error)")
        }
    }
}

// MARK: - Enhanced Confession Model

extension Confession {
    var userReaction: ConfessionReaction? {
        get {
            // TODO: Get from user defaults or backend
            return nil
        }
        set {
            // TODO: Save to user defaults or backend
        }
    }
    
    mutating func addReaction(_ reaction: ConfessionReaction) {
        let currentCount = reactions[reaction] ?? 0
        reactions[reaction] = currentCount + 1
    }
    
    mutating func removeReaction(_ reaction: ConfessionReaction) {
        let currentCount = reactions[reaction] ?? 0
        reactions[reaction] = max(0, currentCount - 1)
    }
}

// MARK: - Mock Data Extensions

extension ConfessionsViewModel {
    static func createMockViewModel() -> ConfessionsViewModel {
        let viewModel = ConfessionsViewModel()
        
        // Create some mock confessions
        viewModel.confessions = [
            Confession(
                content: "I've been pretending to be confident in my relationship, but honestly, I'm terrified of getting hurt again. My last breakup left me feeling like I wasn't enough, and even though my current partner is amazing, I keep waiting for them to realize they can do better. I know this fear is pushing them away, but I don't know how to stop it.",
                mood: .anxious,
                reactions: [
                    .heart: 23,
                    .relate: 45,
                    .support: 12,
                    .strength: 8
                ]
            ),
            Confession(
                content: "Today I realized I've been settling in my dating life because I was afraid of being alone. I finally had the courage to end things with someone who wasn't right for me, even though they were 'good on paper.' It's scary but also liberating. I'm learning that being single and happy is better than being in a relationship and unfulfilled.",
                mood: .grateful,
                reactions: [
                    .heart: 67,
                    .relate: 34,
                    .support: 28,
                    .strength: 19
                ]
            ),
            Confession(
                content: "I keep comparing myself to my partner's ex on social media and it's driving me crazy. I know it's toxic but I can't seem to stop. They look so perfect together in old photos and I feel like I'll never measure up. How do you stop competing with a ghost?",
                mood: .sad,
                reactions: [
                    .heart: 15,
                    .relate: 52,
                    .support: 31,
                    .strength: 7
                ]
            ),
            Confession(
                content: "After months of failed dating app conversations, I finally met someone who makes me laugh until my stomach hurts. We talked for 6 hours straight on our first date and it felt like coming home. I forgot that connection could feel this natural and easy. Maybe I needed all those bad dates to appreciate this one.",
                mood: .happy,
                reactions: [
                    .heart: 89,
                    .relate: 23,
                    .support: 45,
                    .strength: 12
                ]
            ),
            Confession(
                content: "I told my crush how I felt and they said they needed time to think about it. It's been a week and the uncertainty is killing me. Part of me wishes I never said anything because now our friendship feels different. But another part of me is proud for being honest about my feelings for once.",
                mood: .confused,
                reactions: [
                    .heart: 34,
                    .relate: 67,
                    .support: 23,
                    .strength: 15
                ]
            )
        ]
        
        // Add timestamps to make them feel real
        for i in 0..<viewModel.confessions.count {
            let hoursAgo = Double(i + 1) * 2
            viewModel.confessions[i] = Confession(
                id: viewModel.confessions[i].id,
                content: viewModel.confessions[i].content,
                createdAt: Date().addingTimeInterval(-hoursAgo * 3600),
                likes: viewModel.confessions[i].likes,
                comments: viewModel.confessions[i].comments,
                mood: viewModel.confessions[i].mood,
                isReported: false,
                reactions: viewModel.confessions[i].reactions
            )
        }
        
        return viewModel
    }
}

// MARK: - Additional Confession Properties

extension Confession {
    var reactions: [ConfessionReaction: Int] {
        get {
            // Convert the existing comments array or create new reactions dict
            // For now, return a mock reactions dictionary
            return [
                .heart: Int.random(in: 5...50),
                .relate: Int.random(in: 10...80),
                .support: Int.random(in: 3...30),
                .strength: Int.random(in: 1...20)
            ]
        }
        set {
            // TODO: Implement proper storage
        }
    }
    
    init(id: String = UUID().uuidString, content: String, createdAt: Date = Date(), likes: Int = 0, comments: [ConfessionComment] = [], mood: ConfessionMood, isReported: Bool = false, reactions: [ConfessionReaction: Int] = [:]) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.likes = likes
        self.comments = comments
        self.mood = mood
        self.isReported = isReported
        // Note: reactions property is computed, so we don't store it directly
    }
} 