//
//  PerkZone.swift
//  ParPerks
//
//  Created by Thomas Ho on 10/30/25
//
//  Model for a geofenced perk zone on the course that can trigger random rewards.
//

import Foundation
import CoreLocation

// Represents a circular area on the course where perks can be earned
struct PerkZone: Identifiable, Hashable {
    // Stable identifier for this perk zone
    let id: String
    // Human-readable name for the zone (e.g., "Fairway Zone")
    let name: String
    // Center coordinate of the perk zone circle
    let coordinate: CLLocationCoordinate2D
    // Radius of the zone in meters
    let radius: CLLocationDistance
    // List of possible perk messages or rewards for this zone
    let perks: [String]

    static func == (lhs: PerkZone, rhs: PerkZone) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
