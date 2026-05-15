//
//  LobbyScreen.swift
//  ParPerks
//
//  Created by Thomas Ho on 9/18/25
//
//  Pre-game lobby where players confirm the course, edit player names, and start the round.
//

import SwiftUI

// Lobby screen for a selected course, showing players and start-game controls
struct LobbyScreen: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss

    @State private var players: [Player] = [Player(name: "You", isCurrentUser: true)]
    @State private var editingPlayerId: UUID?
    @State private var goToGame = false

    // Simple player model for the lobby list
    struct Player: Identifiable {
        let id = UUID()
        var name: String
        let isCurrentUser: Bool
    }

    private let playerColors: [Color] = [.green, .blue, .purple, .red]
    private let maxFormWidth: CGFloat = 400
    private let sidePadding: CGFloat = 16

    var body: some View {
        NavigationStack {
            ZStack {
                Image("GolfBackground").resizable().scaledToFill().ignoresSafeArea()
                LinearGradient(colors: [.black.opacity(0.65), .black.opacity(0.25), .black.opacity(0.70)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 40)

                        // Lobby title and selected course name
                        VStack(spacing: 8) {
                            Text("Game Lobby")
                                .font(.system(size: 32, weight: .heavy, design: .rounded))
                                .foregroundStyle(LinearGradient(colors: [.white, .green.opacity(0.85)],
                                                               startPoint: .top, endPoint: .bottom))
                                .shadow(color: .black.opacity(0.35), radius: 10, y: 4)

                            Text("at \(course.name)")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }

                        // Selected course summary card
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "flag.fill").foregroundStyle(.white)
                                Text("Selected Course").foregroundStyle(.white).font(.headline)
                                Spacer()
                            }

                            VStack(spacing: 8) {
                                Text(course.name)
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(.white)

                                Text("\(course.city), \(course.state)")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
                        }
                        .padding(14)
                        .frame(maxWidth: maxFormWidth)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.25), lineWidth: 1))
                        .padding(.horizontal, sidePadding)

                        // Player list and add/start controls
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "person.3fill").foregroundStyle(.white)
                                Text("Players in Lobby (\(players.count))").foregroundStyle(.white).font(.headline)
                                Spacer()
                                Button(action: addPlayer) {
                                    Image(systemName: "person.badge.plus")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .disabled(players.count >= 4)
                            }

                            LazyVStack(spacing: 8) {
                                ForEach(0..<players.count, id: \.self) { index in
                                    let p = players[index]
                                    let isEditingRow = (editingPlayerId == p.id)
                                    let color = playerColors[index % playerColors.count]

                                    PlayerRow(
                                        player: $players[index],
                                        playerIndex: index,
                                        playerColor: color,
                                        isEditing: isEditingRow,
                                        onEdit: {
                                            if isEditingRow { editingPlayerId = nil }
                                            else { editingPlayerId = p.id }
                                        },
                                        onDelete: { removePlayer(p) },
                                        canDelete: !p.isCurrentUser && players.count > 1
                                    )
                                }
                            }
                            
                            if !players.isEmpty {
                                Button(action: { goToGame = true }) {
                                    HStack { Image(systemName: "play.fill"); Text("Start Game") }
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 150, height: 38)
                                }
                                .buttonStyle(CompactGreenCTA())
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                            }

                            if players.count < 4 {
                                Button(action: addPlayer) {
                                    HStack { Image(systemName: "person.badge.plus"); Text("Add Player") }
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 150, height: 38)
                                }
                                .buttonStyle(CompactGreenCTA())
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: maxFormWidth)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.25), lineWidth: 1))
                        .padding(.horizontal, sidePadding)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                // Custom back button that dismisses the lobby
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold))
                            Text("Back").fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.4))
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.3), lineWidth: 1))
                    }
                }
            }
            // Navigate into the GameScreen using the current user's name
            .navigationDestination(isPresented: $goToGame) {
                GameScreen(course: course, playerName: players.first { $0.isCurrentUser }?.name ?? "You")
            }
        }
        .tint(.white)
        .onTapGesture { editingPlayerId = nil }
    }

    // Add a non-current-user player up to a maximum of four players
    private func addPlayer() {
        let newPlayerNumber = players.filter { !$0.isCurrentUser }.count + 1
        players.append(Player(name: "Player \(newPlayerNumber)", isCurrentUser: false))
    }

    // Remove a player from the lobby by ID
    private func removePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
    }
}

// Row showing a single player, with inline editing and delete support
struct PlayerRow: View {
    @Binding var player: LobbyScreen.Player
    let playerIndex: Int
    let playerColor: Color
    let isEditing: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let canDelete: Bool

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundStyle(playerColor)
                .font(.system(size: 20))

            if isEditing {
                TextField("Player name", text: $player.name)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
                    .onSubmit { onEdit() }
            } else {
                Text(player.name)
                    .foregroundStyle(.white)
                    .font(.body)
                    .onTapGesture { onEdit() }
            }

            Spacer()

            if !isEditing {
                if player.isCurrentUser {
                    Text("You")
                        .font(.caption)
                        .foregroundStyle(playerColor.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(playerColor.opacity(0.2))
                        .cornerRadius(6)
                } else if canDelete {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red.opacity(0.8))
                            .font(.system(size: 18))
                    }
                }
            } else {
                Button("Done") { onEdit() }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(playerColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(playerColor.opacity(0.2))
                    .cornerRadius(6)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.08))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isEditing ? playerColor.opacity(0.4) : Color.white.opacity(0.15),
                        lineWidth: isEditing ? 2 : 1)
        )
    }
}
