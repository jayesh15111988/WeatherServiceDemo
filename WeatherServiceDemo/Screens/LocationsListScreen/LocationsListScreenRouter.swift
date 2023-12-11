//
//  LocationsListScreenRouter.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import WeatherService
import UIKit

final class LocationsListScreenRouter {

    private let navController: UINavigationController
    private let temperatureInfoUtility: TemperatureInfoUtility
    private let jsonFileReader: JSONFileReader

    init(
        navController: UINavigationController,
        temperatureInfoUtility: TemperatureInfoUtility,
        jsonFileReader: JSONFileReader = JSONFileReader()
    ) {
        self.navController = navController
        self.temperatureInfoUtility = temperatureInfoUtility
        self.jsonFileReader = jsonFileReader
    }

    func start() {

        let locationsListViewModel = LocationsListScreenViewModel(jsonFileReader: jsonFileReader, temperatureInfoUtility: self.temperatureInfoUtility)

        let locationsViewController = LocationsListScreenViewController(viewModel: locationsListViewModel, alertDisplayUtility: AlertDisplayUtility())

        locationsListViewModel.view = locationsViewController
        locationsListViewModel.router = self

        self.navController.pushViewController(locationsViewController, animated: true)
    }
    
    /// A method to navigate to favorites page
    /// - Parameters:
    ///   - favoriteLocations: A list of favorite locations passed to the screen
    ///   - favoriteStatusChangedClosure: A closure passed to get notified about change in favorite status
    func navigateToFavoritesPage(
        with favoriteLocations: [Location],
        favoriteStatusChangedClosure: @escaping (String) -> Void
    ) {
        let favoritesPageRouter = FavoriteLocationsListScreenRouter(navController: self.navController, favoriteLocationModels: favoriteLocations, temperatureInfoUtility: temperatureInfoUtility, favoriteStatusChangedClosure: favoriteStatusChangedClosure)
        favoritesPageRouter.start()
    }
    
    /// A method to navigate to temperature forecast details page
    /// - Parameters:
    ///   - location: A location for which we need to know forecast details
    ///   - temperatureInfo: An info about current and forecast temperatures
    func navigateToLocationForecastDetailsPage(with location: Location, temperatureInfo: TemperatureInfo) {

        let forecastDetailsPageRouter = TemperatureDetailsScreenRouter(rootViewController: self.navController, selectedLocation: location, temperatureInfo: temperatureInfo, temperatureInfoUtility: temperatureInfoUtility)
        forecastDetailsPageRouter.start()
    }
}
