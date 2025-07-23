import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            AdviceFeedView()
                .tabItem {
                    Image(systemName: "heart.text.square")
                    Text("Advice")
                }
            
            AskView()
                .tabItem {
                    Image(systemName: "questionmark.circle")
                    Text("Ask")
                }
            
            ConfessionsView()
                .tabItem {
                    Image(systemName: "lock.heart")
                    Text("Confessions")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
} 