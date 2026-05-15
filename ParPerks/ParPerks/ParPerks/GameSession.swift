//
//  GameSession.swift
//  ParPerks
//
//  Created by Thomas Ho on 10/29/25
//
//  Lightweight session model that tracks whether the player is checked into a course.
//

import Foundation

@MainActor
final class GameSession: ObservableObject {
    // The currently active course for this session, if any
    @Published var activeCourse: Course?
    // ID of the course the player is checked into (empty string means not checked in)
    @Published var checkedInCourseId: String = ""

    // Mark the player as checked in to the given course
    func checkIn(to course: Course) {
        activeCourse = course
        checkedInCourseId = course.id
    }

    // Clear the current session and mark the player as checked out
    func checkOut() {
        activeCourse = nil
        checkedInCourseId = ""
    }

    // Convenience flag to see if a game session is active.
    var isCheckedIn: Bool { !checkedInCourseId.isEmpty }
}
