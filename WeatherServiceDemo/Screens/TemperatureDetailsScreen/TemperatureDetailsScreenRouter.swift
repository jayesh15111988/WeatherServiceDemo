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

        let coreDataOperationsUtility = CoreDataOperationsUtility(coreDataStore: CoreDataStore.shared)

        let viewModel = TemperatureDetailsScreenViewModel(temperatureInfo: temperatureInfo, location: selectedLocation, coreDataActionsUtility: coreDataOperationsUtility, temperatureInfoUtility: temperatureInfoUtility)

        let viewController = TemperatureDetailsScreenViewController(viewModel: viewModel, alertDisplayUtility: AlertDisplayUtility())
        viewModel.router = self

        self.rootViewController.pushViewController(viewController, animated: true)
    }
}
