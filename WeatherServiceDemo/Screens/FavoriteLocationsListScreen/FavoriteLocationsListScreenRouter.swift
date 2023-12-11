//
//  FavoriteLocationsListScreenRouter.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import OSLog
import UIKit

import WeatherService

final class FavoriteLocationsListScreenRouter: Router {

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: FavoriteLocationsListScreenRouter.self)
    )

    let rootViewController: UINavigationController
    private let favoriteLocationModels: [Location]
    private let favoriteStatusChangedClosure: (String) -> Void
    private let temperatureInfoUtility: TemperatureInfoUtility

    init(
        navController: UINavigationController,
        favoriteLocationModels: [Location],
        temperatureInfoUtility: TemperatureInfoUtility,
        favoriteStatusChangedClosure: @escaping (String) -> Void
    ) {
        self.rootViewController = navController
        self.favoriteStatusChangedClosure = favoriteStatusChangedClosure
        self.favoriteLocationModels = favoriteLocationModels
        self.temperatureInfoUtility = temperatureInfoUtility
    }

    func start() {
        let viewModel = FavoriteLocationsListScreenViewModel(favoriteLocationModels: self.favoriteLocationModels, temperatureInfoUtility: TemperatureInfoUtility(weatherService: WeatherService()), favoriteStatusChangedClosure: favoriteStatusChangedClosure)

        let viewController = FavoriteLocationsListScreenViewController(viewModel: viewModel, alertDisplayUtility: AlertDisplayUtility())

        let navigationController = UINavigationController(rootViewController: viewController)

        viewModel.router = self
        viewModel.view = viewController

        self.rootViewController.present(navigationController, animated: true)
    }

    func dismiss(completion: (() -> Void)? = nil) {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: completion)
    }

    func navigateToLocationForecastDetailsPage(with location: Location, temperatureInfo: TemperatureInfo) {
        self.dismiss { [weak self] in

            guard let self else {
                Self.logger.error("Self was prematurely removed from the memory while trying to navigate to location forecast details page")
                return
            }

            let forecastDetailsPageRouter = TemperatureDetailsScreenRouter(
                rootViewController: self.rootViewController,
                selectedLocation: location,
                temperatureInfo: temperatureInfo,
                temperatureInfoUtility: temperatureInfoUtility
            )
            forecastDetailsPageRouter.start()
        }
    }
}
