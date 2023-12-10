//
//  TemperatureDetailsScreenRouter.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

import WeatherService

final class TemperatureDetailsScreenRouter: Router {
    
    let rootViewController: UINavigationController
    private let selectedLocation: Location

    init(rootViewController: UINavigationController, selectedLocation: Location) {
        self.rootViewController = rootViewController
        self.selectedLocation = selectedLocation
    }

    func start() {
        let viewModel = TemperatureDetailsScreenViewModel(location: selectedLocation, weatherService: WeatherService())
        let viewController = TemperatureDetailsScreenViewController(viewModel: viewModel, alertDisplayUtility: AlertDisplayUtility())
        viewModel.router = self
        viewModel.view = viewController
        self.rootViewController.pushViewController(viewController, animated: true)
    }
}
