//
//  AuthViewModel.swift
//  ParPerks
//
//  Created by Thomas Ho on 9/18/25
//
//  View model that manages Firebase authentication state, errors, and user profiles.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    // The currently signed-in Firebase user, if any
    @Published var user: User?
    // Optional error message that can be shown in the UI
    @Published var errorText: String?
    // Prevents overlapping auth requests while one is in progress
    @Published var busy = false

    private let db = Firestore.firestore()
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for Firebase auth state changes and keep `user` in sync
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.user = user }
        }
        self.user = Auth.auth().currentUser
    }

    deinit {
        if let h = handle { Auth.auth().removeStateDidChangeListener(h) }
    }

    func clearError() { errorText = nil }

    // Create a new user account and store a profile in Firestore
    func signUp(email: String, password: String, username: String?) async {
        guard !busy else { return }
        busy = true
        defer { busy = false }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user

            try await upsertProfileForCurrentUser(username: username)

            self.errorText = nil
        } catch {
            if let e = error as? LocalizedError, let msg = e.errorDescription {
                self.errorText = msg
            } else {
                self.errorText = error.localizedDescription
            }
        }
    }

    // Sign in an existing user and ensure they have a profile document
    func signIn(email: String, password: String) async {
        guard !busy else { return }
        busy = true
        defer { busy = false }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            
            try await upsertProfileForCurrentUser(username: nil)

            self.errorText = nil
        } catch {
            if let e = error as? LocalizedError, let msg = e.errorDescription {
                self.errorText = msg
            } else {
                self.errorText = error.localizedDescription
            }
        }
    }

    // Sign the current user out and clear local state
    func signOut() async {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            if let e = error as? LocalizedError, let msg = e.errorDescription {
                self.errorText = msg
            } else {
                self.errorText = error.localizedDescription
            }
        }
    }

    // Create or update the current user's profile document in Firestore
    private func upsertProfileForCurrentUser(username: String?) async throws {
        guard let user = Auth.auth().currentUser else { return }

        let fallback = user.email?.split(separator: "@").first.map(String.init)?.lowercased() ?? "user"
        let finalUsername = (username?.isEmpty == false) ? username! : fallback

        try await db.collection("user_profiles").document(user.uid).setData([
            "email": user.email ?? "",
            "username": finalUsername,
            "updatedAt": FieldValue.serverTimestamp(),
            "createdAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}
