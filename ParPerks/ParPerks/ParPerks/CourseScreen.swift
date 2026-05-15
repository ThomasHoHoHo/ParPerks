//
//  CourseScreen.swift
//  ParPerks
//
//  Created by Thomas Ho on 9/25/25
//
//  Screen for selecting a golf course, searching by location, and joining a lobby.
//

import SwiftUI
import CoreLocation

// Simple search model for display-only course results
struct SearchCourse: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let city: String
    let state: String
    let zip: String
}

// Main screen where users pick a course and join or create a lobby
struct CourseScreen: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedState: String? = nil
    @State private var selectedCity: String? = nil
    @State private var lobbyName: String = ""

    @State private var results: [SearchCourse] = []
    @State private var selectedCourse: Course? = nil
    @State private var showDemoOnly = false

    @State private var appear = false
    @FocusState private var focusedField: Field?
    private enum Field: Hashable { case lobby }

    private var keyboardIsUp: Bool { focusedField != nil }
    private var topSpacer: CGFloat { keyboardIsUp ? 12 : 40 }
    private var bottomSpacer: CGFloat { keyboardIsUp ? 12 : 40 }
    private let maxFormWidth: CGFloat = 400
    private let sidePadding: CGFloat = 16

    // Mapping of states to cities used to filter the course list
    private let stateToCities: [String: [String]] = [
        "California": ["San Diego", "La Jolla", "Pebble Beach", "Monterey"],
        "New York": ["Farmingdale"],
        "Florida": ["Ponte Vedra Beach"],
        "Wisconsin": ["Sheboygan"],
        "Utah": ["Salt Lake City", "St. George"]
    ]

    // All available demo courses shown in the search results
    private let allCourses: [SearchCourse] = [
        .init(name: "Torrey Pines (South) Golf Course", city: "La Jolla", state: "California", zip: "92037"),
        .init(name: "Torrey Pines (North) Golf Course", city: "La Jolla", state: "California", zip: "92037"),
        .init(name: "Pebble Beach Golf Links", city: "Pebble Beach", state: "California", zip: "93953"),
        .init(name: "Spyglass Hill Golf Course", city: "Pebble Beach", state: "California", zip: "93953"),
        .init(name: "Bethpage Black Golf Course", city: "Farmingdale", state: "New York", zip: "11735"),
        .init(name: "TPC Sawgrass (Stadium) Golf Course", city: "Ponte Vedra Beach", state: "Florida", zip: "32082"),
        .init(name: "Whistling Straits (Straits) Golf Course", city: "Sheboygan", state: "Wisconsin", zip: "53083"),
        .init(name: "Bonneville Golf Course", city: "Salt Lake City", state: "Utah", zip: "84108"),
        .init(name: "Old Mill Golf Course", city: "Salt Lake City", state: "Utah", zip: "84121"),
        .init(name: "River Oaks Golf Course", city: "Salt Lake City", state: "Utah", zip: "84070"),
        .init(name: "South Mountain Golf Course", city: "Salt Lake City", state: "Utah", zip: "84020"),
        .init(name: "The Ledges Golf Course", city: "St. George", state: "Utah", zip: "84770"),
        .init(name: "Entrada at Snow Canyon Golf Course", city: "St. George", state: "Utah", zip: "84770"),
        .init(name: "Coral Canyon Golf Course", city: "St. George", state: "Utah", zip: "84790"),
        .init(name: "Black Desert Resort Golf Course", city: "St. George", state: "Utah", zip: "84790")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Image("GolfBackground").resizable().scaledToFill().ignoresSafeArea()
                LinearGradient(colors: [.black.opacity(0.65), .black.opacity(0.25), .black.opacity(0.70)],
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: topSpacer)

                        // Title and signed-in user greeting
                        VStack(spacing: 8) {
                            Text("Welcome to")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.white.opacity(0.92))
                            Text("ParPerks")
                                .font(.system(size: 48, weight: .heavy, design: .rounded))
                                .foregroundStyle(LinearGradient(colors: [.white, .green.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                            if let email = auth.user?.email {
                                Text(email).foregroundStyle(.white.opacity(0.85)).font(.subheadline)
                            }
                        }
                        .multilineTextAlignment(.center)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.05), value: appear)

                        // Course search panel (state, city, and results)
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "magnifyingglass.circle.fill").foregroundStyle(.white)
                                Text("Search courses near you").foregroundStyle(.white).font(.headline)
                                Spacer()
                            }

                            HStack(spacing: 10) {
                                Image(systemName: "map.fill").foregroundStyle(.white)
                                Menu {
                                    ForEach(Array(stateToCities.keys.sorted()), id: \.self) { st in
                                        Button(st) {
                                            selectedState = st
                                            selectedCity = nil
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedState ?? "Select State")
                                            .foregroundStyle(.white.opacity(selectedState == nil ? 0.7 : 0.95))
                                        Spacer()
                                        Image(systemName: "chevron.down").foregroundStyle(.white.opacity(0.8))
                                    }
                                }
                            }
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.30), lineWidth: 1))

                            HStack(spacing: 10) {
                                Image(systemName: "building.2.fill").foregroundStyle(.white)
                                Menu {
                                    ForEach(cityOptions(for: selectedState), id: \.self) { ct in
                                        Button(ct) { selectedCity = ct }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedCity ?? "Select City")
                                            .foregroundStyle(.white.opacity(selectedCity == nil ? 0.7 : 0.95))
                                        Spacer()
                                        Image(systemName: "chevron.down").foregroundStyle(.white.opacity(0.8))
                                    }
                                }
                                .disabled(selectedState == nil)
                                .opacity(selectedState == nil ? 0.55 : 1)
                            }
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.30), lineWidth: 1))

                            Button {
                                runSearch()
                                focusedField = nil
                            } label: {
                                Text("Search Courses").fontWeight(.semibold)
                                    .frame(width: 130, height: 25)
                            }
                            .buttonStyle(CompactGreenCTA())
                            .disabled(selectedState == nil)
                            .frame(maxWidth: .infinity)

                            if !results.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Results (\(results.count))")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white.opacity(0.9))

                                    LazyVStack(spacing: 8) {
                                        ForEach(results) { course in
                                            Button { select(course) } label: {
                                                HStack(spacing: 8) {
                                                    Image(systemName: "flag.fill").foregroundStyle(.white.opacity(0.9))
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(course.name).foregroundStyle(.white).font(.headline)
                                                        Text("\(course.city), \(course.state)")
                                                            .foregroundStyle(.white.opacity(0.8))
                                                            .font(.caption)
                                                    }
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .foregroundStyle(.white.opacity(0.7))
                                                        .font(.system(size: 14, weight: .bold))
                                                }
                                                .padding(10)
                                                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.15), lineWidth: 1))
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: maxFormWidth)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.25), lineWidth: 1))
                        .padding(.horizontal, sidePadding)

                        // Lobby join panel where user can enter a lobby name
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "person.3.fill").foregroundStyle(.white)
                                Text("Join Existing Lobby").foregroundStyle(.white).font(.headline)
                                Spacer()
                            }

                            HStack(spacing: 10) {
                                Image(systemName: "rectangle.and.pencil.and.ellipsis").foregroundStyle(.white)
                                TextField("Lobby name", text: $lobbyName)
                                    .foregroundColor(.white)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .focused($focusedField, equals: .lobby)
                            }
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.30), lineWidth: 1))

                            Button {
                                joinLobby(named: lobbyName)
                                focusedField = nil
                            } label: {
                                Text("Join Lobby").fontWeight(.semibold)
                                    .frame(width: 100, height: 25)
                            }
                            .buttonStyle(CompactGreenCTA())
                            .disabled(lobbyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(14)
                        .frame(maxWidth: maxFormWidth)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.25), lineWidth: 1))
                        .padding(.horizontal, sidePadding)

                        Button {
                            Task { await auth.signOut() }
                        } label: {
                            Text("Sign Out").fontWeight(.semibold).foregroundColor(.white)
                                .frame(width: 80, height: 25)
                        }
                        .buttonStyle(CompactGreenCTA())
                        .frame(maxWidth: .infinity)

                        Spacer(minLength: bottomSpacer)
                    }
                    .contentShape(Rectangle())
                }
                // Dismiss keyboard when dragging the scroll view
                .gesture(DragGesture().onChanged { _ in if focusedField != nil { focusedField = nil } })
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear { appear = true }
            .toolbar {
                // Keyboard toolbar "Done" button for text fields
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            // Navigate to LobbyScreen when a playable course is selected
            .navigationDestination(isPresented: Binding(
                get: { selectedCourse != nil },
                set: { if !$0 { selectedCourse = nil } }
            )) {
                if let c = selectedCourse {
                    LobbyScreen(course: c)
                }
            }
            // Alert when user selects a non-demo course
            .alert("Demo course only", isPresented: $showDemoOnly) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("For the capstone demo, only Bonneville is playable.")
            }
        }
        .tint(.white)
        .scrollDismissesKeyboard(.interactively)
        .animation(.easeInOut(duration: 0.2), value: keyboardIsUp)
    }
}

private extension CourseScreen {
    // Return sorted city options for the currently selected state
    func cityOptions(for state: String?) -> [String] {
        guard let st = state else { return [] }
        return stateToCities[st]?.sorted() ?? []
    }

    // Filter all demo courses by selected state and city
    func runSearch() {
        results = allCourses.filter { c in
            (selectedState == nil || c.state == selectedState!) &&
            (selectedCity == nil || c.city == selectedCity!)
        }
    }

    // Handle selecting a search result; only Bonneville is playable in the demo
    func select(_ c: SearchCourse) {
        if c.name == "Bonneville Golf Course" && c.city == "Salt Lake City" && c.state == "Utah" {
            selectedCourse = Course(
                id: "course_bonneville",
                name: "Bonneville Golf Course",
                state: "Utah",
                city: "Salt Lake City",
                coordinate: .init(latitude: 40.744900, longitude: -111.822200),
                radiusMeters: 180,
                hole1Tee: .init(latitude: 40.74730145727415, longitude: -111.82472800360001),
                hole1Pin: .init(latitude: 40.748640, longitude: -111.819640)
            )
        } else {
            showDemoOnly = true
        }
    }

    // Placeholder hook for joining a lobby by name
    func joinLobby(named name: String) {
        print("Joining lobby: \(name)")
    }
}
