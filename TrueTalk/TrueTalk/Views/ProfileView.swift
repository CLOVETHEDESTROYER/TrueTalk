import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingPremiumPaywall = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    xpProgressSection
                    personaSelectionSection
                    badgesSection
                    premiumSection
                    settingsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPremiumPaywall) {
                PremiumPaywallView(viewModel: viewModel)
            }
            .errorAlert(message: viewModel.errorMessage) {
                viewModel.clearError()
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        try? await authManager.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .onAppear {
                viewModel.loadUserProfile()
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Picture
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.primaryBlue, Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                if let user = viewModel.user {
                    Text(user.displayName.prefix(1).uppercased())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }
                
                // Premium badge
                if viewModel.isPremiumUser {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 20))
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                )
                        }
                        Spacer()
                    }
                    .frame(width: 100, height: 100)
                }
            }
            
            // User Info
            VStack(spacing: 4) {
                if let user = viewModel.user {
                    Text(user.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !user.bio.isEmpty {
                        Text(user.bio)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Text("Member since \(user.joinDate.displayString())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Loading...")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    private var xpProgressSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Experience Level")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Level \(viewModel.currentLevel)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryBlue)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("\(viewModel.currentXP) XP")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(viewModel.xpToNextLevel) XP to next level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: viewModel.xpProgress)
                    .progressViewStyle(CustomProgressViewStyle())
                    .frame(height: 8)
            }
            
            // XP Sources
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                XPSourceCard(
                    icon: "heart.fill",
                    title: "Advice Saved",
                    count: viewModel.savedAdviceCount,
                    xpPerAction: 5
                )
                
                XPSourceCard(
                    icon: "questionmark.circle.fill",
                    title: "Questions Asked",
                    count: viewModel.questionsAskedCount,
                    xpPerAction: 10
                )
                
                XPSourceCard(
                    icon: "face.smiling.fill",
                    title: "Reactions Given",
                    count: viewModel.reactionsGivenCount,
                    xpPerAction: 2
                )
                
                XPSourceCard(
                    icon: "star.fill",
                    title: "Daily Streak",
                    count: viewModel.dailyStreak,
                    xpPerAction: 20
                )
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    private var personaSelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Default AI Advisor")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if viewModel.isPremiumUser {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(DatingPersona.allCases, id: \.self) { persona in
                    PersonaSelectionCard(
                        persona: persona,
                        isSelected: viewModel.defaultPersona == persona,
                        isPremiumRequired: !viewModel.isPremiumUser && persona != .bestFriend,
                        onSelect: {
                            if viewModel.isPremiumUser || persona == .bestFriend {
                                viewModel.selectDefaultPersona(persona)
                            } else {
                                showingPremiumPaywall = true
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    private var badgesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(viewModel.earnedBadges.count)/\(viewModel.allBadges.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(viewModel.allBadges, id: \.id) { badge in
                    BadgeCard(
                        badge: badge,
                        isEarned: viewModel.earnedBadges.contains { $0.id == badge.id }
                    )
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    private var premiumSection: some View {
        VStack(spacing: 16) {
            if viewModel.isPremiumUser {
                premiumUserCard
            } else {
                premiumUpgradeCard
            }
        }
    }
    
    private var premiumUserCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("TrueTalk Premium")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Thank you for your support!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                Text("✨ All AI Personas")
                Spacer()
            }
            HStack {
                Text("🚀 Unlimited Questions")
                Spacer()
            }
            HStack {
                Text("💎 Exclusive Badges")
                Spacer()
            }
        }
        .font(.subheadline)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var premiumUpgradeCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Upgrade to Premium")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Unlock all features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                PremiumFeatureRow(icon: "brain.head.profile", text: "Access all AI Personas")
                PremiumFeatureRow(icon: "infinity", text: "Unlimited questions & advice")
                PremiumFeatureRow(icon: "star.fill", text: "Exclusive premium badges")
                PremiumFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced XP bonuses")
            }
            
            Button(action: {
                showingPremiumPaywall = true
            }) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Upgrade Now")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    private var settingsSection: some View {
        VStack(spacing: 0) {
            SettingsRow(
                icon: "pencil",
                title: "Edit Profile",
                action: { viewModel.editProfile() }
            )
            
            Divider()
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "bell",
                title: "Notifications",
                action: { viewModel.openNotificationSettings() }
            )
            
            Divider()
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "questionmark.circle",
                title: "Help & Support",
                action: { viewModel.openSupport() }
            )
            
            Divider()
                .padding(.leading, 50)
            
            SettingsRow(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Sign Out",
                action: { showingSignOutAlert = true },
                isDestructive: true
            )
        }
        .cardStyle()
    }
}

// MARK: - Supporting Views

struct XPSourceCard: View {
    let icon: String
    let title: String
    let count: Int
    let xpPerAction: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.primaryBlue)
                .font(.title2)
            
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("+\(xpPerAction) XP each")
                .font(.caption2)
                .foregroundColor(.primaryBlue)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PersonaSelectionCard: View {
    let persona: DatingPersona
    let isSelected: Bool
    let isPremiumRequired: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Text(persona.emoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(persona.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if isPremiumRequired {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                    
                    Text(persona.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .primaryBlue : .secondary)
                    .font(.title3)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primaryBlue.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.primaryBlue : Color.clear,
                        lineWidth: 2
                    )
            )
            .opacity(isPremiumRequired ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BadgeCard: View {
    let badge: UserBadge
    let isEarned: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isEarned ? Color.primaryBlue.opacity(0.1) : Color(.systemGray6))
                    .frame(width: 50, height: 50)
                
                Text(badge.emoji)
                    .font(.title2)
                    .opacity(isEarned ? 1.0 : 0.3)
            }
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .opacity(isEarned ? 1.0 : 0.5)
            
            if !isEarned {
                Text(badge.requirement)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .font(.subheadline)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : .primaryBlue)
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(isDestructive ? .red : .primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
            
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color.primaryBlue, Color.pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .scaleEffect(x: CGFloat(configuration.fractionCompleted ?? 0), y: 1, anchor: .leading)
        }
    }
}

// MARK: - Premium Paywall View

struct PremiumPaywallView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 60))
                    
                    Text("Unlock TrueTalk Premium")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Get access to all AI personas and unlimited features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Features
                VStack(spacing: 16) {
                    PremiumFeatureRow(icon: "brain.head.profile", text: "Chat with Therapist & No-BS Sis")
                    PremiumFeatureRow(icon: "infinity", text: "Unlimited questions per day")
                    PremiumFeatureRow(icon: "star.fill", text: "Exclusive premium badges")
                    PremiumFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "2x XP multiplier")
                    PremiumFeatureRow(icon: "heart.fill", text: "Priority customer support")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                Spacer()
                
                // Pricing
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.purchasePremium()
                        dismiss()
                    }) {
                        VStack(spacing: 4) {
                            Text("Start Free Trial")
                                .fontWeight(.bold)
                            Text("Then $4.99/month")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    Text("7-day free trial, cancel anytime")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
} 