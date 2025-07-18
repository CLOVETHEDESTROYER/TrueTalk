import SwiftUI

struct AskView: View {
    @StateObject private var viewModel = DatingAdviceViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    personaSelector
                    inputSection
                    submitButton
                    
                    if let advice = viewModel.advice {
                        adviceCard(advice: advice)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .navigationTitle("Dating Advice")
            .navigationBarTitleDisplayMode(.large)
            .errorAlert(message: viewModel.errorMessage) {
                viewModel.clearError()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.pink)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Get Dating Advice")
                        .titleStyle()
                    
                    Text("Choose your advisor and get personalized guidance")
                        .subtitleStyle()
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var personaSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Your Advisor")
                .bodyStyle()
                .fontWeight(.semibold)
            
            Picker("Persona", selection: $viewModel.selectedPersona) {
                ForEach(DatingPersona.allCases, id: \.self) { persona in
                    Text(persona.displayName)
                        .tag(persona)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Persona description
            HStack(spacing: 8) {
                Text(viewModel.selectedPersona.emoji)
                    .font(.title2)
                
                Text(viewModel.selectedPersona.description)
                    .captionStyle()
                    .multilineTextAlignment(.leading)
            }
            .padding(.top, 8)
        }
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("What's Your Situation?")
                    .bodyStyle()
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(viewModel.userInput.count)/500")
                    .captionStyle()
                    .foregroundColor(
                        viewModel.userInput.count > 500 ? .warningRed : .secondary
                    )
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(minHeight: 120)
                
                TextEditor(text: $viewModel.userInput)
                    .padding(16)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                viewModel.userInput.isEmpty ? Color.clear : Color.primaryBlue.opacity(0.3),
                                lineWidth: 2
                            )
                    )
                
                if viewModel.userInput.isEmpty {
                    Text("Share your dating situation, concerns, or questions. Be as detailed as you'd like - your advisor is here to help!")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .allowsHitTesting(false)
                }
            }
        }
    }
    
    private var submitButton: some View {
        Button(action: {
            Task {
                await viewModel.getAdvice()
            }
        }) {
            HStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(viewModel.isLoading ? "Getting advice..." : "Ask \(viewModel.selectedPersona.shortName)")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                viewModel.canSubmit ? Color.primaryBlue : Color.gray
            )
            .cornerRadius(16)
        }
        .disabled(!viewModel.canSubmit)
        .loading(viewModel.isLoading)
    }
    
    private func adviceCard(advice: DatingAdvice) -> some View {
        VStack(spacing: 16) {
            // Header with persona
            HStack {
                HStack(spacing: 12) {
                    Text(advice.persona.emoji)
                        .font(.system(size: 32))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Advice from your \(advice.persona.displayName)")
                            .bodyStyle()
                            .fontWeight(.semibold)
                        
                        Text(advice.timestamp.displayString())
                            .captionStyle()
                    }
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.shareAdvice(advice)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primaryBlue)
                        .font(.system(size: 18))
                }
            }
            
            Divider()
            
            // Advice content
            ScrollView {
                Text(advice.content)
                    .bodyStyle()
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
            .frame(maxHeight: 300)
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.likeAdvice(advice)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: advice.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(advice.isLiked ? .pink : .secondary)
                        
                        if advice.likes > 0 {
                            Text("\(advice.likes)")
                                .captionStyle()
                        }
                    }
                }
                
                Spacer()
                
                Button("Ask Follow-up") {
                    viewModel.prepareFollowUp()
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primaryBlue)
                
                Button("Clear") {
                    viewModel.clearAdvice()
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .cardStyle()
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeInOut(duration: 0.3), value: advice.id)
    }
}

// MARK: - Supporting Types

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
}

struct DatingAdvice: Identifiable {
    let id = UUID()
    let content: String
    let persona: DatingPersona
    let timestamp: Date
    var isLiked: Bool = false
    var likes: Int = 0
    
    init(content: String, persona: DatingPersona) {
        self.content = content
        self.persona = persona
        self.timestamp = Date()
    }
}

// MARK: - ViewModel

@MainActor
class DatingAdviceViewModel: ObservableObject {
    @Published var selectedPersona: DatingPersona = .bestFriend
    @Published var userInput = ""
    @Published var advice: DatingAdvice?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
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
            
            self.advice = DatingAdvice(
                content: adviceContent,
                persona: selectedPersona
            )
            
            self.isLoading = false
            
        } catch {
            self.errorMessage = "Failed to get advice: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func likeAdvice(_ advice: DatingAdvice) {
        guard let currentAdvice = self.advice, currentAdvice.id == advice.id else { return }
        
        var updatedAdvice = currentAdvice
        updatedAdvice.isLiked.toggle()
        updatedAdvice.likes += updatedAdvice.isLiked ? 1 : -1
        
        self.advice = updatedAdvice
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
}

#Preview {
    AskView()
} 