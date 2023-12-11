//
//  AppRouter.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

import WeatherService

/// An app router to initialize app routing beginning
final class AppRouter: Router {
    
    private let window: UIWindow

    var rootViewController: UINavigationController

    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UINavigationController()
    }

    func start() {
        let locationsScreenRouter = LocationsListScreenRouter(navController: self.rootViewController, temperatureInfoUtility: TemperatureInfoUtility(weatherService: WeatherService()))
        locationsScreenRouter.start()

        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()
    }
}
