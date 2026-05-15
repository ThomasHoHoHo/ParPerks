//
//  GameScreen.swift
//  ParPerks
//
//  Created by Thomas Ho on 9/30/25
//
//  Map-based game screen that shows the current hole, user location, score, and perk zones.
//

import SwiftUI
import MapKit

// Main gameplay screen for a single hole with map, score, and perks
struct GameScreen: View {
    @StateObject var geo = GeofenceManager.shared
    @StateObject var session = GameSession()
    let course: Course
    let playerName: String

    @State private var camera: MapCameraPosition
    @State private var region: MKCoordinateRegion
    @State private var camDistance: CLLocationDistance
    @State private var center17: CLLocationCoordinate2D
    @State private var score: Int = 0
    @State private var isHoleInfoExpanded = false
    
    @State private var showSpinningWheel = false
    @State private var activePerkZone: PerkZone? = nil

    // Demo perk zone on the fairway for triggering the spinning wheel
    private let fairwayZone = PerkZone(
        id: "fairway_zone_1",
        name: "Fairway Zone",
        coordinate: .init(latitude: 40.7473429900337, longitude: -111.8221570226605),
        radius: 8,
        perks: ["Get a Mulligan!", "Take Two Shots!", "Tee up the ball!", "Replace your ball with another person!", "Move your ball 50 yards ahead!"]
    )

    // Approximate coordinate for the first green
    private let hole1GreenCoordinate = CLLocationCoordinate2D(
        latitude: 40.74747121817548,
        longitude: -111.82033989612437
    )
    // Toggle for showing the outer course geofence overlay (used for debugging/demo)
    private let showGeofenceOverlay = false

    init(course: Course, playerName: String) {
        self.course = course
        self.playerName = playerName

        // Compute mid-point between tee and green to center the map
        let teeCoordinate = course.startCenter
        let greenCoordinate = hole1GreenCoordinate

        let centerLatitude = (teeCoordinate.latitude + greenCoordinate.latitude) / 2
        let centerLongitude = (teeCoordinate.longitude + greenCoordinate.longitude) / 2
        let midpointCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)

        // Use tee–green distance to scale the initial camera
        let teeLocation = CLLocation(latitude: teeCoordinate.latitude, longitude: teeCoordinate.longitude)
        let greenLocation = CLLocation(latitude: greenCoordinate.latitude, longitude: greenCoordinate.longitude)
        let holeDistance = teeLocation.distance(from: greenLocation)
        let initialCameraDistance = holeDistance * 2.2
        
        // Region span roughly covering tee and green
        let latDelta = abs(teeCoordinate.latitude - greenCoordinate.latitude)
        let lonDelta = abs(teeCoordinate.longitude - greenCoordinate.longitude)
        let initialSpan = MKCoordinateSpan(latitudeDelta: latDelta * 1.4, longitudeDelta: lonDelta * 1.4)
        let initialRegion = MKCoordinateRegion(center: midpointCoordinate, span: initialSpan)

        _center17 = State(initialValue: midpointCoordinate)
        _camDistance = State(initialValue: initialCameraDistance)
        _region = State(initialValue: initialRegion)

        // Use new MapCamera API on iOS 17, region-based fallback otherwise
        if #available(iOS 17.0, *) {
            let heading = course.hole1Heading ?? 0
            let cam = MapCamera(centerCoordinate: midpointCoordinate,
                                distance: initialCameraDistance,
                                heading: heading,
                                pitch: 55)
            _camera = State(initialValue: .camera(cam))
        } else {
            _camera = State(initialValue: .region(initialRegion))
        }
    }

    var body: some View {
        ZStack {
            mapView.ignoresSafeArea()

            VStack {
                HStack(alignment: .top, spacing: 12) {
                    scoreMenuView
                    Spacer()
                    holeInfoView
                }
                .padding(.horizontal)
                .padding(.top, 12)

                Spacer()

                // Map zoom controls
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Button(action: zoomIn) { Image(systemName: "plus") }
                            .buttonStyle(MapButtonStyle())
                        Button(action: zoomOut) { Image(systemName: "minus") }
                            .buttonStyle(MapButtonStyle())
                    }
                    .padding(.trailing, 12)
                    .padding(.bottom, 24)
                }
            }

            // Show "Check In" button when user is inside the course geofence
            if geo.insideCourseId == course.id && !session.isCheckedIn {
                VStack {
                    Spacer()
                    Button("Check In to \(course.name)") { session.checkIn(to: course) }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            geo.requestPermissions()
            geo.monitor(course: course)
            geo.monitor(perkZone: fairwayZone)
        }
        .onDisappear { geo.stopMonitoringAll() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) { titleView } }
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        // Listen for geofence perk zone entry and trigger spinning wheel
        .onReceive(geo.$enteredPerkZone) { newZone in

            print("GameScreen received an update from GeofenceManager. New zone: \(newZone?.name ?? "nil")")
            
            guard let zone = newZone else { return }
            guard !showSpinningWheel else {
                print("   -> Spinning wheel already showing, ignoring.")
                return
            }
            
            activePerkZone = zone
            showSpinningWheel = true
            print("   -> Triggering spinning wheel!")
        }
        // Present spinning wheel when a perk zone is active
        .sheet(isPresented: $showSpinningWheel) {
            geo.enteredPerkZone = nil
        } content: {
            if let zone = activePerkZone {
                SpinningWheelView(perks: zone.perks, isPresented: $showSpinningWheel)
            }
        }
    }

    // Re-center and rotate the map to focus on hole 1
    private func focusHole1() {
        if #available(iOS 17.0, *) {
            let heading = course.hole1Heading ?? 0
            withAnimation {
                camDistance = _camDistance.wrappedValue
                center17 = _center17.wrappedValue
                camera = .camera(.init(centerCoordinate: center17,
                                       distance: camDistance,
                                       heading: heading,
                                       pitch: 55))
            }
        } else {
            withAnimation {
                region = _region.wrappedValue
            }
        }
    }

    private func zoomIn()  { adjustZoom(factor: 0.75) }
    private func zoomOut() { adjustZoom(factor: 1.33) }

    // Adjust map zoom, clamping distance/span to a reasonable range
    private func adjustZoom(factor: Double) {
        if #available(iOS 17.0, *) {
            camDistance = max(60, min(3000, camDistance * factor))
            let heading = course.hole1Heading ?? 0
            withAnimation {
                camera = .camera(.init(centerCoordinate: center17,
                                       distance: camDistance,
                                       heading: heading,
                                       pitch: 55))
            }
        } else {
            let lat = max(0.0005, min(0.2, region.span.latitudeDelta * factor))
            let lon = max(0.0005, min(0.2, region.span.longitudeDelta * factor))
            withAnimation { region.span = .init(latitudeDelta: lat, longitudeDelta: lon) }
        }
    }

    // Hybrid map showing user location, tee, green, and perk zone
    @ViewBuilder
    private var mapView: some View {
        if #available(iOS 17.0, *) {
            Map(position: $camera) {
                UserAnnotation()
                Marker("Hole 1 Tee", coordinate: course.startCenter)
                Marker("Green", systemImage: "flag.fill", coordinate: hole1GreenCoordinate)
                    .tint(.green)

                MapCircle(center: fairwayZone.coordinate, radius: fairwayZone.radius)
                    .foregroundStyle(.red.opacity(0.3))
                    .stroke(.red.opacity(0.8), lineWidth: 1.5)
                
                if showGeofenceOverlay {
                    MapCircle(center: course.startCenter, radius: course.radiusMeters)
                        .foregroundStyle(.green.opacity(0.18))
                }
            }
            .mapStyle(.hybrid)
        } else {
            GeofenceMap(center: course.startCenter,
                        pin: course.hole1Pin,
                        greenPin: hole1GreenCoordinate,
                        radiusMeters: course.radiusMeters,
                        region: $region,
                        followUser: true,
                        showOverlay: showGeofenceOverlay)
        }
    }

    // Navigation bar title showing course name and flag icon
    private var titleView: some View {
        HStack(spacing: 8) {
            Image(systemName: "flag.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
            Text(course.name)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(LinearGradient(colors: [.white, .green.opacity(0.85)],
                                                startPoint: .top, endPoint: .bottom))
                .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
    
    // Score button that lets the player quickly adjust their score relative to par
    @ViewBuilder
    private var scoreMenuView: some View {
        Menu {
            ForEach(-3...5, id: \.self) { value in
                Button(scoreText(for: value)) {
                    score = value
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "figure.golf")
                    .font(.body.weight(.semibold))
                VStack(alignment: .leading, spacing: 1) {
                    Text(playerName)
                        .font(.caption.weight(.bold))
                    Text("Score: \(scoreText(for: score))")
                        .font(.headline.weight(.semibold))
                        .contentTransition(.numericText())
                        .animation(.easeInOut, value: score)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.20, green: 0.70, blue: 0.30),
                                     Color(red: 0.10, green: 0.60, blue: 0.20)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.28), radius: 8, y: 4)
        }
    }
    
    // Hole information panel with tee yardages and "Leave Game" when checked in
    @ViewBuilder
    private var holeInfoView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Hole 1")
                        .font(.title3.weight(.bold))
                    Text("Par 5")
                        .font(.headline.weight(.medium))
                }
                
                Spacer()
                
                Button(action: focusHole1) {
                    Image(systemName: "scope")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .rotationEffect(.degrees(isHoleInfoExpanded ? 180 : 0))
                    .padding(.top, 6)
            }
            .foregroundStyle(.white)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isHoleInfoExpanded.toggle()
                }
            }

            if isHoleInfoExpanded {
                Divider().background(.white.opacity(0.4))
                VStack(alignment: .leading, spacing: 4) {
                    TeeInfoRow(color: .black, textColor: .white, name: "Black", yards: 480)
                    TeeInfoRow(color: .blue, textColor: .white, name: "Blue", yards: 456)
                    TeeInfoRow(color: .white, textColor: .black, name: "White", yards: 430)
                    TeeInfoRow(color: .yellow, textColor: .black, name: "Gold", yards: 370)
                }
                if session.isCheckedIn {
                    Button("Leave Game") {
                        session.checkOut()
                        geo.stopMonitoringAll()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 4)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.20, green: 0.70, blue: 0.30),
                                 Color(red: 0.10, green: 0.60, blue: 0.20)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
        )
        .frame(width: 170)
        .shadow(color: .black.opacity(0.28), radius: 8, y: 4)
    }

    // Convert a relative score into a short label (e.g., -1 → "-1", 0 → "E", +2 → "+2")
    private func scoreText(for value: Int) -> String {
        if value == 0 { return "E" }
        return value > 0 ? "+\(value)" : "\(value)"
    }
}

// Row showing a single tee color and its yardage
struct TeeInfoRow: View {
    let color: Color
    let textColor: Color
    let name: String
    let yards: Int

    var body: some View {
        HStack(spacing: 8) {
            Text(name)
                .font(.caption.weight(.bold))
                .foregroundStyle(textColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay {
                    if color == .white {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(.black.opacity(0.4), lineWidth: 1)
                    }
                }

            Text("- \(yards) yards")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.95))
        }
    }
}

// Button style for the map zoom controls
struct MapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.weight(.bold))
            .frame(width: 44, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.20, green: 0.70, blue: 0.30),
                                     Color(red: 0.10, green: 0.60, blue: 0.20)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            )
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.28), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

// UIKit-backed map view for pre–iOS 17 devices with geofence overlays
struct GeofenceMap: UIViewRepresentable {
    var center: CLLocationCoordinate2D
    var pin: CLLocationCoordinate2D?
    var greenPin: CLLocationCoordinate2D?
    var radiusMeters: CLLocationDistance
    @Binding var region: MKCoordinateRegion
    var followUser: Bool = true
    var showOverlay: Bool = false

    class Coordinator: NSObject, MKMapViewDelegate {}
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.mapType = .hybrid
        map.showsUserLocation = true
        map.userTrackingMode = followUser ? .follow : .none
        map.showsCompass = true
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.isRotateEnabled = true
        map.isPitchEnabled = true
        map.setRegion(region, animated: false)

        // Aim the camera from tee toward the pin for a more immersive view
        let heading = pin.flatMap { bearing(from: center, to: $0) } ?? 0
        let cam = MKMapCamera(lookingAtCenter: center, fromDistance: 320, pitch: 55, heading: heading)
        map.setCamera(cam, animated: false)

        let teeAnno = MKPointAnnotation()
        teeAnno.coordinate = center
        teeAnno.title = "Hole 1 Tee"
        map.addAnnotation(teeAnno)
        
        if let green = greenPin {
            let greenAnno = MKPointAnnotation()
            greenAnno.coordinate = green
            greenAnno.title = "Green"
            map.addAnnotation(greenAnno)
        }

        if showOverlay {
            map.addOverlay(MKCircle(center: center, radius: radiusMeters))
        }
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.setRegion(region, animated: true)
    }

    // Compute compass bearing (degrees 0–360) from point `a` to point `b`
    private func bearing(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> CLLocationDirection {
        let φ1 = a.latitude * .pi / 180
        let φ2 = b.latitude * .pi / 180
        let Δλ = (b.longitude - a.longitude) * .pi / 180
        let y = sin(Δλ) * cos(φ2)
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)
        var θ = atan2(y, x) * 180 / .pi
        if θ < 0 { θ += 360 }
        return θ
    }
}
