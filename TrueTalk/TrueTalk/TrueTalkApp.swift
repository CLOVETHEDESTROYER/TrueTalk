//
//  TrueTalkApp.swift
//  TrueTalk
//
//  Created by Xander on 7/21/25.
//

import SwiftUI
import SwiftData

@main
struct TrueTalkApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: Item.self, configurations: modelConfiguration)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated || authManager.isGuestMode {
                MainTabView()
                    .environmentObject(authManager)
            } else {
                AuthenticationView()
                    .environmentObject(authManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
