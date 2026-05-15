//
//  HomeScreen.swift
//  ParPerks
//
//  Created by Thomas Ho on 9/18/25
//
//  Landing screen that shows the golf hero background and navigation to Log In / Sign Up.
//

import SwiftUI

// Reusable golf background with image and dark gradient overlay
struct GolfBG: View {
    var body: some View {
        ZStack {
            Image("GolfBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .black.opacity(0.65),
                    .black.opacity(0.25),
                    .black.opacity(0.70)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

// Main landing screen with title, tagline, and navigation to auth screens
struct HomeScreen: View {
    // Controls the initial fade/slide-in of the title and buttons
    @State private var appear = false

    var body: some View {
        NavigationStack {
            ZStack {
                GolfBG()

                VStack(spacing: 20) {
                    Spacer().frame(height: 90)

                    // Title + tagline
                    VStack(spacing: 8) {
                        Text("ParPerks")
                            .font(.system(size: 56, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.white, .green.opacity(0.85)],
                                               startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: .black.opacity(0.4), radius: 10, y: 4)

                        Text("Golf Game to Earn Perks")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.white.opacity(0.95))
                            .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
                    }
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.05), value: appear)

                    Spacer()

                    // Navigation buttons for auth screens
                    VStack(spacing: 16) {
                        NavigationLink { LoginScreen() } label: {
                            Text("Log In").fontWeight(.semibold)
                        }
                        .buttonStyle(GolfActionButtonStyle(buttonType: .primary))

                        NavigationLink { SignupScreen() } label: {
                            Text("Sign Up").fontWeight(.semibold)
                        }
                        .buttonStyle(GolfActionButtonStyle(buttonType: .secondary))
                    }
                    .padding(.horizontal, 40)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.15), value: appear)

                    Spacer(minLength: 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear { appear = true }
        }
    }
}

// Type of golf-themed button used on the home screen
enum GolfButtonType { case primary, secondary }

// Shared button style for primary and secondary golf buttons
struct GolfActionButtonStyle: ButtonStyle {
    var buttonType: GolfButtonType = .primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                Group {
                    if buttonType == .primary {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.20, green: 0.70, blue: 0.30),
                                             Color(red: 0.10, green: 0.60, blue: 0.20)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.22))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(red: 0.20, green: 0.70, blue: 0.30),
                                                     Color(red: 0.10, green: 0.60, blue: 0.20)],
                                            startPoint: .leading, endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                    }
                }
            )
            .foregroundStyle(buttonType == .primary ? .white : .green)
            .font(.headline)
            .shadow(color: .black.opacity(buttonType == .primary ? 0.30 : 0.20),
                    radius: buttonType == .primary ? 10 : 6,
                    y: buttonType == .primary ? 5 : 3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
