//
//  LocationsListScreenRouter.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

final class LocationsListScreenRouter {

    private let navController: UINavigationController

    init(navController: UINavigationController) {
        self.navController = navController
    }

    func start() {
        let locationsListViewModel = LocationsListScreenViewModel(jsonFileReader: JSONFileReader())
        let locationsViewController = LocationsListScreenViewController(viewModel: locationsListViewModel)

        locationsListViewModel.view = locationsViewController
        locationsListViewModel.router = self

        self.navController.pushViewController(locationsViewController, animated: true)
    }
}
