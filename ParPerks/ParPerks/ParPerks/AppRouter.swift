//
//  AppRouter.swift
//  ParPerks
//
//  Created by Thomas Ho on 9/25/25
//
//  Handles simple top-level navigation by tracking the current app route.
//

import Foundation

//Top-level routes for the app’s navigation
enum AppRoute: Equatable {
    case home
    case course
}

// Shared router that controls which screen is shown
final class AppRouter: ObservableObject {
    // The current active route (default is the home screen)
    @Published var route: AppRoute = .home
}
