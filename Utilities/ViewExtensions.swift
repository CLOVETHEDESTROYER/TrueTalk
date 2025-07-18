import SwiftUI

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(isLoading ? 0.6 : 1.0)
                .disabled(isLoading)
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.2)
            }
        }
    }
}

struct ErrorAlertModifier: ViewModifier {
    let errorMessage: String?
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    onDismiss()
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func loading(_ isLoading: Bool) -> some View {
        modifier(LoadingModifier(isLoading: isLoading))
    }
    
    func errorAlert(message: String?, onDismiss: @escaping () -> Void) -> some View {
        modifier(ErrorAlertModifier(errorMessage: message, onDismiss: onDismiss))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Color Extensions

extension Color {
    static let primaryBlue = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let secondaryBlue = Color(red: 0.4, green: 0.6, blue: 0.9)
    static let accentOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warningRed = Color(red: 0.9, green: 0.2, blue: 0.2)
    
    // Mood colors for confessions
    static func moodColor(for mood: ConfessionMood) -> Color {
        switch mood {
        case .happy: return .yellow
        case .sad: return .blue
        case .angry: return .red
        case .anxious: return .orange
        case .grateful: return .green
        case .confused: return .purple
        case .excited: return .pink
        case .neutral: return .gray
        }
    }
}

// MARK: - Text Extensions

extension Text {
    func titleStyle() -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.primary)
    }
    
    func subtitleStyle() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    func bodyStyle() -> some View {
        self
            .font(.body)
            .foregroundColor(.primary)
    }
    
    func captionStyle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.secondary)
    }
} 