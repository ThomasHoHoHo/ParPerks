//
//  ParPerksApp.swift
//  ParPerks
//
//  Created by Thomas Ho on 9/18/25
//
//  App entry point that configures Firebase and chooses between Home and Course screens based on auth state.
//

import SwiftUI
import FirebaseCore

@main
struct ParPerksApp: App {
    // Shared authentication view model for the whole app
    @StateObject private var auth = AuthViewModel()
    // Simple router for top-level navigation
    @StateObject private var router = AppRouter()

    init() {
        // Configure Firebase as soon as the app launches
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(router)
        }
    }
}

// Root container that decides which screen to show based on login state
struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        Group {
            if auth.user != nil {
                CourseScreen()
            } else {
                HomeScreen()
            }
        }
    }
}

// Simple logged-in placeholder screen (kept for reference/debugging)
struct LoggedInScreen: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        ZStack {
            Image("GolfBackground").resizable().scaledToFill().ignoresSafeArea()
            LinearGradient(colors: [.black.opacity(0.65), .black.opacity(0.25), .black.opacity(0.70)],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("ParPerks")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text(auth.user?.email ?? "")
                    .foregroundStyle(.white.opacity(0.9))
                Button("Sign Out") { Task { await auth.signOut() } }
                    .buttonStyle(CompactGreenCTA())
            }
            .padding()
        }
    }
}
