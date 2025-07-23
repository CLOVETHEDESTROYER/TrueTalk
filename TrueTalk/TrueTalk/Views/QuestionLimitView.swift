import SwiftUI

struct QuestionLimitView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showAuthentication = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            // Title
            Text("Daily Limit Reached")
                .font(.title)
                .fontWeight(.bold)
            
            // Message
            VStack(spacing: 15) {
                Text("You've used all 3 free questions for today.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                
                Text("Sign up for unlimited questions and access to all features!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Features list
            VStack(alignment: .leading, spacing: 10) {
                Text("Unlimited features include:")
                    .font(.headline)
                
                FeatureRow(icon: "infinity", text: "Unlimited questions per day")
                FeatureRow(icon: "heart.fill", text: "Access to all advice and confessions")
                FeatureRow(icon: "person.2.fill", text: "Connect with other users")
                FeatureRow(icon: "star.fill", text: "Build your reputation")
                FeatureRow(icon: "bell.fill", text: "Get notifications for responses")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Action buttons
            VStack(spacing: 15) {
                Button(action: { showAuthentication = true }) {
                    Text("Sign Up for Free")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: { showAuthentication = true }) {
                    Text("Already have an account? Sign In")
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showAuthentication) {
            AuthenticationView()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

#Preview {
    QuestionLimitView()
} 