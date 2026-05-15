//
//  SignupScreen.swift
//  ParPerks
//
//  Created by Thomas Ho on 9/18/25
//
//  Sign-up screen where new users create a ParPerks account and profile.
//

import SwiftUI

// Screen for creating a new ParPerks account with email, username, and password
struct SignupScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirm = ""
    // Controls fade/slide-in animation of the header and form
    @State private var appear = false
    
    // Tracks which input field is currently focused for keyboard navigation
    @FocusState private var focusedField: Field?
    private enum Field: Hashable { case email, username, password, confirm }

    private let maxFormWidth: CGFloat = 360
    private let sidePadding: CGFloat = 20

    // Basic password rule: length + at least one uppercase + one symbol
    private var passwordValid: Bool {
        password.count >= 6 &&
        password.range(of: "[A-Z]", options: .regularExpression) != nil &&
        password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
    }

    // Overall form validation used to enable/disable the create account button
    private var formValid: Bool {
        !email.isEmpty && email.contains("@") && passwordValid && password == confirm
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Background image with gradient overlay
                Image("GolfBackground").resizable().scaledToFill().ignoresSafeArea()
                LinearGradient(colors: [.black.opacity(0.65), .black.opacity(0.25), .black.opacity(0.70)],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                // Tap background to dismiss keyboard (behind content)
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { focusedField = nil }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        // Static spacer so layout doesn’t jump with keyboard
                        Spacer().frame(height: 60)

                        // Title area
                        VStack(spacing: 8) {
                            Text("Create Your Account")
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

                        // Form fields and create account button
                        VStack(spacing: 16) {
                            // Email
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
                                    .onSubmit { focusedField = .username }
                            }
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.30), lineWidth: 1))

                            // Username
                            HStack(spacing: 10) {
                                Image(systemName: "person.fill").foregroundStyle(.white)
                                TextField("", text: $username,
                                          prompt: Text("Username").foregroundColor(.white.opacity(0.9)))
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .foregroundColor(.white)
                                    .submitLabel(.next)
                                    .focused($focusedField, equals: .username)
                                    .onSubmit { focusedField = .password }
                            }
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.30), lineWidth: 1))

                            // Password
                            HStack(spacing: 10) {
                                Image(systemName: "lock.fill").foregroundStyle(.white)
                                SecureField("", text: $password,
                                            prompt: Text("Password").foregroundColor(.white.opacity(0.9)))
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .foregroundColor(.white)
                                    .submitLabel(.next)
                                    .focused($focusedField, equals: .password)
                                    .onSubmit { focusedField = .confirm }
                            }
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.30), lineWidth: 1))

                            // Password rule text
                            Text("Password must be at least 6 characters and include 1 uppercase letter and 1 symbol.")
                                .font(.headline)
                                .foregroundStyle(passwordValid || password.isEmpty ? .white.opacity(0.9) : .red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)

                            // Confirm
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(.white)
                                SecureField("", text: $confirm,
                                            prompt: Text("Confirm Password").foregroundColor(.white.opacity(0.9)))
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .foregroundColor(.white)
                                    .submitLabel(.go)
                                    .focused($focusedField, equals: .confirm)
                                    .onSubmit {
                                        Task { await auth.signUp(email: email, password: password, username: username) }
                                    }
                            }
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.30), lineWidth: 1))

                            // Create Account button
                            Button {
                                Task { await auth.signUp(email: email, password: password, username: username) }
                            } label: {
                                Group {
                                    if auth.busy { ProgressView().progressViewStyle(.circular) }
                                    else { Text("CREATE ACCOUNT").fontWeight(.semibold) }
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(CompactGreenCTA())
                            .disabled(auth.busy || !formValid)

                            // Back to Log In
                            HStack(spacing: 6) {
                                Text("Already have an account?").font(.caption).foregroundStyle(.white.opacity(0.75))
                                Button("Log In") { dismiss() }
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
                // Slight delay to focus the email field after the view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { focusedField = .email }
            }
            // Compact back button overlaid at the top
            .overlay(alignment: .topLeading) {
                Button("Back") { dismiss() }
                    .buttonStyle(CompactGreenCTA(small: true))
                    .padding(.leading, 16)
                    .padding(.top, 12)
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
