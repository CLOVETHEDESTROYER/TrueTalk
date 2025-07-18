import SwiftUI

struct ConfessionsView: View {
    @StateObject private var viewModel = ConfessionsViewModel()
    @State private var showingSubmissionForm = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerSection
                confessionsFeed
            }
            .navigationTitle("Confessions")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSubmissionForm) {
                ConfessionSubmissionView(viewModel: viewModel)
            }
            .errorAlert(message: viewModel.errorMessage) {
                viewModel.clearError()
            }
            .onAppear {
                viewModel.loadConfessions()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Anonymous Stories")
                        .titleStyle()
                    
                    Text("Share your truth in a safe space")
                        .subtitleStyle()
                }
                
                Spacer()
                
                Button(action: {
                    showingSubmissionForm = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Share")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Anonymous reminder
            HStack(spacing: 8) {
                Image(systemName: "eye.slash.circle.fill")
                    .foregroundColor(.secondary)
                
                Text("All confessions are completely anonymous")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    private var confessionsFeed: some View {
        Group {
            if viewModel.isLoading && viewModel.confessions.isEmpty {
                loadingView
            } else if viewModel.confessions.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.confessions) { confession in
                            ConfessionCardView(
                                confession: confession,
                                onReaction: { reaction in
                                    viewModel.reactToConfession(confession: confession, reaction: reaction)
                                },
                                onRespond: {
                                    // TODO: Implement response functionality
                                    print("Respond to confession: \(confession.id)")
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .refreshable {
                    await viewModel.refreshConfessions()
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading stories...")
                .subtitleStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundColor(.purple.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Stories Yet")
                    .titleStyle()
                
                Text("Be the first to share an anonymous story with the community")
                    .subtitleStyle()
                    .multilineTextAlignment(.center)
            }
            
            Button("Share Your Story") {
                showingSubmissionForm = true
            }
            .buttonStyle(ConfessionButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}

struct ConfessionSubmissionView: View {
    @ObservedObject var viewModel: ConfessionsViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextEditorFocused: Bool
    @State private var confessionText = ""
    @State private var selectedMood: ConfessionMood = .neutral
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    submissionHeader
                    moodSelector
                    textInputSection
                    submitSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Share Anonymously")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .errorAlert(message: viewModel.errorMessage) {
                viewModel.clearError()
            }
        }
    }
    
    private var submissionHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "eye.slash.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.purple.opacity(0.7))
            
            VStack(spacing: 8) {
                Text("Your Story, Your Truth")
                    .titleStyle()
                    .multilineTextAlignment(.center)
                
                Text("Share what's on your heart. This is a judgment-free zone where your identity stays completely private.")
                    .subtitleStyle()
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How are you feeling?")
                .bodyStyle()
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ConfessionMood.allCases, id: \.self) { mood in
                        MoodChip(
                            mood: mood,
                            isSelected: selectedMood == mood
                        ) {
                            selectedMood = mood
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }
    
    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Story")
                    .bodyStyle()
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(confessionText.count)/1000")
                    .captionStyle()
                    .foregroundColor(
                        confessionText.count > 1000 ? .warningRed : .secondary
                    )
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(minHeight: 200)
                
                TextEditor(text: $confessionText)
                    .focused($isTextEditorFocused)
                    .padding(16)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isTextEditorFocused ? Color.purple.opacity(0.5) : Color.clear,
                                lineWidth: 2
                            )
                    )
                
                if confessionText.isEmpty {
                    Text("Share your thoughts, experiences, or feelings. This could be something you've never told anyone, a lesson you've learned, or just what's weighing on your heart right now...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .allowsHitTesting(false)
                }
            }
            
            // Guidelines
            VStack(alignment: .leading, spacing: 8) {
                Text("Community Guidelines:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    GuidelineRow(text: "Be respectful and kind")
                    GuidelineRow(text: "No personal attacks or harmful content")
                    GuidelineRow(text: "Your confession remains completely anonymous")
                }
            }
            .padding(.top, 8)
        }
    }
    
    private var submitSection: some View {
        VStack(spacing: 16) {
            if let successMessage = viewModel.successMessage {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.successGreen)
                    
                    Text(successMessage)
                        .bodyStyle()
                        .foregroundColor(.successGreen)
                }
                .padding()
                .background(Color.successGreen.opacity(0.1))
                .cornerRadius(12)
            }
            
            Button(action: {
                Task {
                    await submitConfession()
                }
            }) {
                HStack(spacing: 12) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "heart.circle.fill")
                    }
                    
                    Text(viewModel.isSubmitting ? "Sharing..." : "Share Anonymously")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: canSubmit ? [Color.purple, Color.pink] : [Color.gray, Color.gray],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            .disabled(!canSubmit || viewModel.isSubmitting)
        }
    }
    
    private var canSubmit: Bool {
        !confessionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        confessionText.count <= 1000
    }
    
    private func submitConfession() async {
        let confession = Confession(
            content: confessionText.trimmingCharacters(in: .whitespacesAndNewlines),
            mood: selectedMood
        )
        
        await viewModel.submitConfession(confession)
        
        if viewModel.successMessage != nil {
            confessionText = ""
            selectedMood = .neutral
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }
}

struct ConfessionCardView: View {
    let confession: Confession
    let onReaction: (ConfessionReaction) -> Void
    let onRespond: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with mood and time
            HStack {
                HStack(spacing: 8) {
                    Text(confession.mood.emoji)
                        .font(.title2)
                    
                    Text(confession.mood.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(confession.createdAt.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Confession content
            Text(confession.content)
                .bodyStyle()
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            // Reaction buttons
            HStack(spacing: 16) {
                ForEach(ConfessionReaction.allCases, id: \.self) { reaction in
                    Button(action: {
                        onReaction(reaction)
                    }) {
                        HStack(spacing: 6) {
                            Text(reaction.emoji)
                                .font(.system(size: 18))
                            
                            if let count = confession.reactions[reaction], count > 0 {
                                Text("\(count)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    confession.userReaction == reaction 
                                    ? Color.purple.opacity(0.2) 
                                    : Color(.systemGray6)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    confession.userReaction == reaction 
                                    ? Color.purple.opacity(0.5) 
                                    : Color.clear,
                                    lineWidth: 1
                                )
                        )
                    }
                    .scaleEffect(confession.userReaction == reaction ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: confession.userReaction)
                }
                
                Spacer()
                
                // Respond button
                Button(action: onRespond) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 14))
                        
                        Text("Respond")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.purple.opacity(0.1))
                    )
                }
            }
            
            // Coming soon note for responses
            HStack {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("Response feature coming soon")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
    }
}

// MARK: - Supporting Views

struct MoodChip: View {
    let mood: ConfessionMood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 18))
                
                Text(mood.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected 
                        ? Color.purple
                        : Color(.systemGray6)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

struct GuidelineRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption2)
                .foregroundColor(.green)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ConfessionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Supporting Types

enum ConfessionReaction: String, CaseIterable {
    case heart = "💗"
    case relate = "🤝"
    case support = "🫂"
    case strength = "💪"
    
    var emoji: String {
        return self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .heart: return "Heart"
        case .relate: return "Relate"
        case .support: return "Support" 
        case .strength: return "Strength"
        }
    }
}

#Preview {
    ConfessionsView()
} 