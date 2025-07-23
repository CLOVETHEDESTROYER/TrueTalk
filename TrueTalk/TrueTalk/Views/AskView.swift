import SwiftUI

struct AskView: View {
    @StateObject private var viewModel = DatingAdviceViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showQuestionLimit = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    // Show question limit info for guests
                    if !authManager.isAuthenticated {
                        questionLimitInfo
                    }
                    
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
            .sheet(isPresented: $showQuestionLimit) {
                QuestionLimitView()
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
    
    private var questionLimitInfo: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Guest Mode")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Text(authManager.getRemainingQuestions() == -1 ? "Unlimited questions" : "\(authManager.getRemainingQuestions()) questions remaining today")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Sign Up") {
                showQuestionLimit = true
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var submitButton: some View {
        Button(action: {
            if authManager.canAskQuestion() {
                Task {
                    await viewModel.getAdvice()
                    authManager.recordQuestionAsked()
                }
            } else {
                showQuestionLimit = true
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
                viewModel.canSubmit && authManager.canAskQuestion() ? Color.primaryBlue : Color.gray
            )
            .cornerRadius(16)
        }
        .disabled(!viewModel.canSubmit || !authManager.canAskQuestion())
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

#Preview {
    AskView()
} 