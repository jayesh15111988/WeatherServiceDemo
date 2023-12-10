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

    init(navController: UINavigationController, favoriteLocationModels: [Location]) {
        self.rootViewController = navController
        self.favoriteLocationModels = favoriteLocationModels
    }

    func start() {
        let viewModel = FavoriteLocationsListScreenViewModel(favoriteLocationModels: self.favoriteLocationModels)

        let viewController = FavoriteLocationsListScreenViewController(viewModel: viewModel, alertDisplayUtility: AlertDisplayUtility())

        let navigationController = UINavigationController(rootViewController: viewController)

        viewModel.router = self

        self.rootViewController.present(navigationController, animated: true)
    }
}
