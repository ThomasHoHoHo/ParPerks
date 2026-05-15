//
//  GeofenceManager.swift
//  ParPerks
//
//  Created by Thomas Ho on 10/29/25
//
//  Singleton that manages CoreLocation permissions, course geofences, and perk zones.
//

import Foundation
import CoreLocation

@MainActor
final class GeofenceManager: NSObject, ObservableObject {
    // Shared instance used across the app
    static let shared = GeofenceManager()
    
    // Current authorization status for location services
    @Published var authorization: CLAuthorizationStatus = .notDetermined
    // Current accuracy authorization (full vs reduced)
    @Published var accuracyAuthorization: CLAccuracyAuthorization = .reducedAccuracy
    // ID of the course region the user is currently inside, if any
    @Published var insideCourseId: String? = nil
    
    // The most recent perk zone the user has entered
    @Published var enteredPerkZone: PerkZone? = nil

    private let manager = CLLocationManager()
    // In-memory cache of perk zones we are monitoring, keyed by ID
    private var monitoredPerkZones: [PerkZone] = []

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = true
        authorization = manager.authorizationStatus
        accuracyAuthorization = manager.accuracyAuthorization
    }

    // Request appropriate location permissions for geofencing
    func requestPermissions() {
        if authorization == .notDetermined {
            manager.requestWhenInUseAuthorization()
            return
        }
        if authorization == .authorizedWhenInUse {
            manager.requestAlwaysAuthorization()
        }
    }

    func startUpdating() { manager.startUpdatingLocation() }
    func stopUpdating() { manager.stopUpdatingLocation() }

    // Start monitoring the geofence around a given course
    func monitor(course: Course) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        let identifier = "course_\(course.id)"
        let region = CLCircularRegion(center: course.startCenter, radius: course.radiusMeters, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        manager.startMonitoring(for: region)
    }

    // Start monitoring a perk zone region that can trigger rewards
    func monitor(perkZone: PerkZone) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        let identifier = "perk_\(perkZone.id)"
        let region = CLCircularRegion(center: perkZone.coordinate, radius: perkZone.radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        monitoredPerkZones.append(perkZone)
        manager.startMonitoring(for: region)
    }

    // Stop monitoring all geofences and clear any cached perk zones
    func stopMonitoringAll() {
        monitoredPerkZones = []
        for r in manager.monitoredRegions {
            manager.stopMonitoring(for: r)
        }
    }
}

extension GeofenceManager: CLLocationManagerDelegate {
    // Keep published authorization state in sync and start updates when allowed
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorization = manager.authorizationStatus
            self.accuracyAuthorization = manager.accuracyAuthorization
            if self.authorization == .authorizedAlways || self.authorization == .authorizedWhenInUse {
                self.startUpdating()
            }
        }
    }

    // Handle entering either a perk zone or a course region based on the identifier prefix
    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        Task { @MainActor in
            if region.identifier.starts(with: "perk_") {
                // Look up the matching perk zone from the cache
                if let zone = self.monitoredPerkZones.first(where: { "perk_\($0.id)" == region.identifier }) {
                    self.enteredPerkZone = zone
                }
            } else if region.identifier.starts(with: "course_") {
                // Strip "course_" to get the original course ID
                let courseId = String(region.identifier.dropFirst(7))
                self.insideCourseId = courseId
            }
        }
    }

    // Handle exiting perk zones and course regions, clearing state when we leave
    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        Task { @MainActor in
            if region.identifier.starts(with: "perk_") {
                // If we leave the same zone we entered, reset perk state
                if self.enteredPerkZone?.id == String(region.identifier.dropFirst(5)) {
                    self.enteredPerkZone = nil
                }
            } else if region.identifier.starts(with: "course_") {
                let courseId = String(region.identifier.dropFirst(7))
                if self.insideCourseId == courseId {
                    self.insideCourseId = nil
                }
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
}
