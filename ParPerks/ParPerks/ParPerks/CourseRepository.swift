//
//  CourseRepository.swift
//  ParPerks
//
//  Created by Thomas Ho on 10/29/25
//
//  Static repository that defines built-in demo courses used by the app.
//

import CoreLocation

// Namespace for predefined demo courses
enum CoursesRepository {
    // Bonneville Golf Course with basic location and hole 1 coordinates
    static let bonneville = Course(
        id: "course_bonneville",
        name: "Bonneville Golf Course",
        state: "Utah",
        city: "Salt Lake City",
        coordinate: .init(latitude: 40.744900, longitude: -111.822200),
        radiusMeters: 180,
        hole1Tee: .init(latitude: 40.74730145727415, longitude: -111.82472800360001),
        hole1Pin: .init(latitude: 40.748640, longitude: -111.819640)
    )

    // All available courses bundled in the app
    static let all: [Course] = [bonneville]
}
