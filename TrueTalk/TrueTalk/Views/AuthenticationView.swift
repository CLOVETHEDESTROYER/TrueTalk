import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("TrueTalk")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Get advice, share confessions, ask questions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Form
                VStack(spacing: 20) {
                    if isSignUp {
                        TextField("Display Name", text: $displayName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: handleAuthentication) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty || (isSignUp && displayName.isEmpty))
                }
                .padding(.horizontal)
                
                // Toggle between sign in and sign up
                Button(action: { isSignUp.toggle() }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                
                // Continue as guest
                if !isSignUp {
                    VStack(spacing: 10) {
                        Text("Or")
                            .foregroundColor(.secondary)
                        
                        Button("Continue as Guest") {
                            authManager.enableGuestMode()
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func handleAuthentication() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                if isSignUp {
                    try await authManager.signUp(email: email, password: password, displayName: displayName)
                } else {
                    try await authManager.signIn(email: email, password: password)
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    AuthenticationView()
} 