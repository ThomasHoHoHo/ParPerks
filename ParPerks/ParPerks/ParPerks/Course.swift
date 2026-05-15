//
//  Course.swift
//  ParPerks
//
//  Created by Thomas Ho on 10/29/25
//
//  Model for a golf course with location data used for maps and geofences.
//

import CoreLocation

// Represents a single golf course and its key coordinates.
struct Course: Identifiable, Hashable {
    let id: String
    let name: String
    let state: String
    let city: String
    let coordinate: CLLocationCoordinate2D
    let radiusMeters: CLLocationDistance

    // Tee coordinate for hole 1
    let hole1Tee: CLLocationCoordinate2D?
    // Pin/green coordinate for hole 1
    let hole1Pin: CLLocationCoordinate2D?
    
    var startCenter: CLLocationCoordinate2D { hole1Tee ?? coordinate }

    // Heading from hole 1 tee to pin, used for map rotation or overlays
    var hole1Heading: CLLocationDirection? {
        guard let tee = hole1Tee, let pin = hole1Pin else { return nil }
        return Course.bearing(from: tee, to: pin)
    }

    static func == (lhs: Course, rhs: Course) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    init(
        id: String,
        name: String,
        state: String,
        city: String,
        coordinate: CLLocationCoordinate2D,
        radiusMeters: CLLocationDistance,
        hole1Tee: CLLocationCoordinate2D? = nil,
        hole1Pin: CLLocationCoordinate2D? = nil
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.city = city
        self.coordinate = coordinate
        self.radiusMeters = radiusMeters
        self.hole1Tee = hole1Tee
        self.hole1Pin = hole1Pin
    }

    // Compute compass bearing (degrees 0–360) from point `a` to point `b`
    private static func bearing(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> CLLocationDirection {
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
