//
//  FavoriteLocationsListScreenRouter.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

final class FavoriteLocationsListScreenRouter: Router {

    let rootViewController: UINavigationController
    private let favoriteLocationModels: [Location]
    private let favoriteStatusChangedClosure: (String) -> Void

    init(navController: UINavigationController, favoriteLocationModels: [Location], favoriteStatusChangedClosure: @escaping (String) -> Void) {
        self.rootViewController = navController
        self.favoriteStatusChangedClosure = favoriteStatusChangedClosure
        self.favoriteLocationModels = favoriteLocationModels
    }

    func start() {
        let viewModel = FavoriteLocationsListScreenViewModel(favoriteLocationModels: self.favoriteLocationModels, favoriteStatusChangedClosure: favoriteStatusChangedClosure)

        let viewController = FavoriteLocationsListScreenViewController(viewModel: viewModel, alertDisplayUtility: AlertDisplayUtility())

        let navigationController = UINavigationController(rootViewController: viewController)

        viewModel.router = self
        viewModel.view = viewController

        self.rootViewController.present(navigationController, animated: true)
    }

    func dismiss(completion: (() -> Void)? = nil) {
        self.rootViewController.presentedViewController?.dismiss(animated: true, completion: completion)
    }

    func navigateToLocationForecastDetailsPage(with location: Location) {
        self.dismiss { [weak self] in

            guard let self else { return }

            let forecastDetailsPageRouter = TemperatureDetailsScreenRouter(rootViewController: self.rootViewController, selectedLocation: location)
            forecastDetailsPageRouter.start()
        }
    }
}
