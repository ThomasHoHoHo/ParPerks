//
//  LoginScreen.swift
//  ParPerks
//
//  Created by Thomas Ho on 9/18/25
//
//  Login screen where users enter email/password and sign in via Firebase.
//

import SwiftUI

// Screen for returning users to log in with their ParPerks account
struct LoginScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    // Controls fade/slide-in animation of the header and form
    @State private var appear = false
    
    // Focus State for managing keyboard focus between fields
    @FocusState private var focusedField: Field?
    private enum Field: Hashable { case email, password }

    @Environment(\.dismiss) private var dismiss

    private let maxFormWidth: CGFloat = 360
    private let sidePadding: CGFloat = 20

    var body: some View {
        NavigationStack {
            ZStack {
                // Background layer with golf image and gradient overlay
                Image("GolfBackground").resizable().scaledToFill().ignoresSafeArea()
                LinearGradient(colors: [.black.opacity(0.65), .black.opacity(0.25), .black.opacity(0.70)],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                // Tap outside to dismiss keyboard
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = nil
                    }

                // Main scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        // Use a static spacer so layout stays stable when keyboard appears
                        Spacer().frame(height: 60)

                        VStack(spacing: 8) {
                            Text("Welcome Back to")
                                .font(.title2.weight(.medium))
                                .foregroundStyle(.white.opacity(0.92))
                                .shadow(radius: 6)
                            Text("ParPerks")
                                .font(.system(size: 56, weight: .heavy, design: .rounded))
                                .foregroundStyle(LinearGradient(colors: [.white, .green.opacity(0.85)],
                                                               startPoint: .top, endPoint: .bottom))
                                .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.1), value: appear)

                        // Email/password form and login button
                        VStack(spacing: 16) {
                            HStack(spacing: 10) {
                                Image(systemName: "envelope.fill").foregroundStyle(.white)
                                TextField("", text: $email,
                                          prompt: Text("Email").foregroundColor(.white.opacity(0.9)))
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .foregroundColor(.white)
                                    .submitLabel(.next)
                                    .focused($focusedField, equals: .email)
                                    .onSubmit { focusedField = .password }
                            }
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.30), lineWidth: 1))

                            HStack(spacing: 10) {
                                Image(systemName: "lock.fill").foregroundStyle(.white)
                                SecureField("", text: $password,
                                            prompt: Text("Password").foregroundColor(.white.opacity(0.9)))
                                    .textContentType(.password)
                                    .foregroundColor(.white)
                                    .submitLabel(.go)
                                    .focused($focusedField, equals: .password)
                                    .onSubmit { Task { await auth.signIn(email: email, password: password) } }
                            }
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.30), lineWidth: 1))

                            Button {
                                Task { await auth.signIn(email: email, password: password) }
                            } label: {
                                Group {
                                    if auth.busy { ProgressView().progressViewStyle(.circular) }
                                    else { Text("LOG IN").fontWeight(.semibold) }
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(CompactGreenCTA())
                            .disabled(auth.busy || email.isEmpty || password.isEmpty)

                            HStack(spacing: 6) {
                                Text("Don't have an account?").font(.caption).foregroundStyle(.white.opacity(0.75))
                                NavigationLink("Sign Up") { SignupScreen() }
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                            .padding(.top, 8)

                            if let e = auth.errorText {
                                Text(e).font(.footnote).foregroundStyle(.red).multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: maxFormWidth)
                        .padding(.horizontal, sidePadding)

                        Spacer(minLength: 72)
                    }
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                appear = true
                // Delay focus slightly to ensure view layout is complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { focusedField = .email }
            }
            // Compact back button overlaid at the top.
            .overlay(alignment: .topLeading) {
                Button("Back") { dismiss() }
                    .buttonStyle(CompactGreenCTA(small: true))
                    .padding(.leading, 16)
                    .padding(.top, 30)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
        }
        .tint(.white)
    }
}
