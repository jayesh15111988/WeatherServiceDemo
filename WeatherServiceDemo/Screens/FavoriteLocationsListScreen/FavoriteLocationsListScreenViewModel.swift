//
//  FavoriteLocationsListScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import Combine
import Foundation

final class FavoriteLocationsListScreenViewModel {

    @Published var isLoading = false
    @Published var alertInfo: AlertInfo?
    var favoriteLocationModels: [Location]
    let title: String
    private let temperatureInfoUtility: TemperatureInfoUtility
    private let coreDataOperationsUtility: CoreDataOperationsUtility

    var router: FavoriteLocationsListScreenRouter?
    let favoriteStatusChangedClosure: (String) -> Void

    init(
        favoriteLocationModels: [Location],
        temperatureInfoUtility: TemperatureInfoUtility,
        coreDataOperationsUtility: CoreDataOperationsUtility,
        favoriteStatusChangedClosure: @escaping (String) -> Void) {
            self.favoriteLocationModels = favoriteLocationModels
            self.temperatureInfoUtility = temperatureInfoUtility
            self.coreDataOperationsUtility = coreDataOperationsUtility
            self.favoriteStatusChangedClosure = favoriteStatusChangedClosure
            self.title = "Favorites"
    }
    
    /// A method to remove location at index from the favorites list
    /// - Parameter index: An index of location in the array
    func removeLocationFromFavorites(at index: Int) {

        let favoriteLocationToRemove = favoriteLocationModels[index]

        //Toggle favorite status of current location
        favoriteLocationToRemove.toggleFavoriteStatus()

        //Remove temperature data for location from the local cache
        self.coreDataOperationsUtility.removeTemperatureData(for: favoriteLocationToRemove.id)

        //Remove location from the favorites list
        favoriteLocationModels.remove(at: index)

        //Notify the change in favorite status of given location
        favoriteStatusChangedClosure(favoriteLocationToRemove.id)

        if favoriteLocationModels.isEmpty {
            self.alertInfo = AlertInfo(title: "No Favorites", message: "You don't have any favorites. Please click on star icon to add location to favorites list")
        }
    }

    func goToLocationForecastDetailsPage(with location: Location) {

        self.isLoading = true

        //Try to load weather data for the location
        self.temperatureInfoUtility.loadWeatherInformation(with: location) { result in
            switch result {
            case .success(let temperatureInfo):

                self.router?.navigateToLocationForecastDetailsPage(with: location, temperatureInfo: .init(currentTemperatureViewModel: temperatureInfo.0, temperatureForecastViewModels: temperatureInfo.1))

            case .failure(let failure):
                self.alertInfo = AlertInfo(title: "Error", message: failure.errorMessageString())
            }
            self.isLoading = false
        }
    }

    func dismissCurrentView() {
        router?.dismiss()
    }
}
