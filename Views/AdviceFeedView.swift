import SwiftUI

struct AdviceFeedView: View {
    @StateObject private var viewModel = AdviceFeedViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.primaryBlue.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    cardStackArea
                    actionButtons
                }
            }
            .navigationTitle("Advice Feed")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadAdviceCards()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover Wisdom")
                        .titleStyle()
                    
                    Text("Swipe through personalized advice")
                        .subtitleStyle()
                }
                
                Spacer()
                
                // Stats
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .font(.caption)
                        Text("\(viewModel.savedAdvice.count)")
                            .captionStyle()
                            .fontWeight(.medium)
                    }
                    
                    Text("saved")
                        .captionStyle()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
    }
    
    private var cardStackArea: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.currentCards.isEmpty {
                    emptyStateView
                } else {
                    // Card stack - show top 3 cards
                    ForEach(Array(viewModel.currentCards.prefix(3).enumerated()), id: \.element.id) { index, card in
                        AdviceCardView(
                            card: card,
                            index: index,
                            onSwipe: { direction in
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    viewModel.handleSwipe(card: card, direction: direction)
                                }
                            },
                            onReaction: { reaction in
                                viewModel.reactToCard(card: card, reaction: reaction)
                            }
                        )
                        .scaleEffect(1.0 - (CGFloat(index) * 0.05))
                        .offset(y: CGFloat(index) * 4)
                        .zIndex(Double(3 - index))
                    }
                }
            }
        }
        .frame(maxHeight: 500)
        .padding(.horizontal, 20)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 40) {
            // Dismiss button
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    viewModel.dismissCurrentCard()
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.red)
                    .frame(width: 60, height: 60)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(viewModel.currentCards.isEmpty)
            
            // Save button
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    viewModel.saveCurrentCard()
                }
            }) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.pink)
                    .frame(width: 60, height: 60)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(viewModel.currentCards.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.primaryBlue)
            
            VStack(spacing: 8) {
                Text("All Caught Up!")
                    .titleStyle()
                
                Text("You've seen all the available advice. Check back later for more wisdom!")
                    .subtitleStyle()
                    .multilineTextAlignment(.center)
            }
            
            Button("Reload Cards") {
                viewModel.reloadCards()
            }
            .buttonStyle(PrimaryCardButtonStyle())
        }
        .padding(40)
    }
}

struct AdviceCardView: View {
    let card: AdviceCard
    let index: Int
    let onSwipe: (SwipeDirection) -> Void
    let onReaction: (EmojiReaction) -> Void
    
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    @State private var dragOffset: CGSize = .zero
    
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 0) {
                // Persona header
                personaHeader
                
                // Advice content
                adviceContent
                
                // Reaction buttons
                reactionButtons
            }
        }
        .frame(height: 400)
        .offset(x: offset.x + dragOffset.x, y: offset.y + dragOffset.y)
        .rotationEffect(.degrees(rotation + (Double(offset.x + dragOffset.x) / 10)))
        .opacity(index == 0 ? 1.0 : 0.8)
        .scaleEffect(index == 0 ? 1.0 : 0.95)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if index == 0 {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    if index == 0 {
                        handleDragEnd(value: value)
                    }
                }
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: offset)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: rotation)
    }
    
    private var personaHeader: some View {
        HStack(spacing: 12) {
            Text(card.persona.emoji)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(card.persona.displayName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryBlue)
                
                Text(card.timestamp.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Swipe indicators
            HStack(spacing: 8) {
                if dragOffset.x < -50 {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                        .opacity(min(abs(dragOffset.x) / 100, 1.0))
                }
                
                if dragOffset.x > 50 {
                    Image(systemName: "heart.circle.fill")
                        .foregroundColor(.pink)
                        .font(.title2)
                        .opacity(min(abs(dragOffset.x) / 100, 1.0))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(card.persona.backgroundColor.opacity(0.1))
        )
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    private var adviceContent: some View {
        ScrollView {
            Text(card.content)
                .font(.body)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
        }
        .frame(maxHeight: 200)
    }
    
    private var reactionButtons: some View {
        HStack(spacing: 20) {
            ForEach(EmojiReaction.allCases, id: \.self) { reaction in
                Button(action: {
                    onReaction(reaction)
                }) {
                    VStack(spacing: 4) {
                        Text(reaction.emoji)
                            .font(.system(size: 24))
                        
                        Text("\(card.reactions[reaction] ?? 0)")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                            .opacity(card.userReaction == reaction ? 1.0 : 0.5)
                    )
                }
                .scaleEffect(card.userReaction == reaction ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: card.userReaction)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func handleDragEnd(value: DragGesture.Value) {
        let swipeDistance = value.translation.x
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if abs(swipeDistance) > swipeThreshold {
                // Trigger swipe
                let direction: SwipeDirection = swipeDistance > 0 ? .right : .left
                
                // Animate card off screen
                offset = CGSize(
                    width: swipeDistance > 0 ? 500 : -500,
                    height: value.translation.y + Double.random(in: -100...100)
                )
                rotation = swipeDistance > 0 ? 30 : -30
                
                // Call completion after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onSwipe(direction)
                    resetCard()
                }
            } else {
                // Snap back to center
                dragOffset = .zero
            }
        }
    }
    
    private func resetCard() {
        offset = .zero
        rotation = 0
        dragOffset = .zero
    }
}

// MARK: - Supporting Types

enum SwipeDirection {
    case left, right
}

enum EmojiReaction: String, CaseIterable {
    case love = "💗"
    case fire = "🔥"
    case cry = "😭"
    
    var emoji: String {
        return self.rawValue
    }
}

struct AdviceCard: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let persona: DatingPersona
    let timestamp: Date
    var reactions: [EmojiReaction: Int] = [:]
    var userReaction: EmojiReaction?
    var isSaved: Bool = false
    
    init(content: String, persona: DatingPersona) {
        self.content = content
        self.persona = persona
        self.timestamp = Date().addingTimeInterval(Double.random(in: -86400...0)) // Random time in last 24h
        
        // Initialize with random reactions
        for reaction in EmojiReaction.allCases {
            reactions[reaction] = Int.random(in: 0...50)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AdviceCard, rhs: AdviceCard) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Extensions

extension DatingPersona {
    var backgroundColor: Color {
        switch self {
        case .bestFriend: return .pink
        case .therapist: return .blue
        case .noBSSis: return .purple
        }
    }
}

struct PrimaryCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.primaryBlue)
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    AdviceFeedView()
} 