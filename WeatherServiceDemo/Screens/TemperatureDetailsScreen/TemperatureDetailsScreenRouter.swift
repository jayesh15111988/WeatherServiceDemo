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
    private let temperatureInfo: TemperatureInfo
    private let temperatureInfoUtility: TemperatureInfoUtility

    init(
        rootViewController: UINavigationController,
        selectedLocation: Location,
        temperatureInfo: TemperatureInfo,
        temperatureInfoUtility: TemperatureInfoUtility
    ) {
        self.rootViewController = rootViewController
        self.selectedLocation = selectedLocation
        self.temperatureInfo = temperatureInfo
        self.temperatureInfoUtility = temperatureInfoUtility
    }

    func start() {
        let viewModel = TemperatureDetailsScreenViewModel(temperatureInfo: temperatureInfo, location: selectedLocation, temperatureInfoUtility: temperatureInfoUtility)

        let viewController = TemperatureDetailsScreenViewController(viewModel: viewModel, alertDisplayUtility: AlertDisplayUtility())
        viewModel.router = self
        viewModel.view = viewController
        self.rootViewController.pushViewController(viewController, animated: true)
    }
}
