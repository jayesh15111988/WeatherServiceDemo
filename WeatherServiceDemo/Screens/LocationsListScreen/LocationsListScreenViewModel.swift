//
//  LocationsListScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import CoreLocation
import OSLog

final class LocationsListScreenViewModel {

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: LocationsListScreenViewModel.self)
    )

    
    var router: LocationsListScreenRouter?

    private var locationsListScreenLocationModels: [Location] = []
    let jsonFileReader: JSONFileReadable
    let temperatureInfoUtility: TemperatureInfoUtility
    private let coreDataActionsUtility: CoreDataOperationsUtility

    @Published var isLoading = false
    @Published var locations: [Location] = []
    @Published var cellIndexToReload: Int?
    @Published var alertInfo: AlertInfo?

    let title: String

    init(
        jsonFileReader: JSONFileReadable,
        temperatureInfoUtility: TemperatureInfoUtility,
        coreDataActionsUtility: CoreDataOperationsUtility
    ) {
        self.jsonFileReader = jsonFileReader
        self.temperatureInfoUtility = temperatureInfoUtility
        self.coreDataActionsUtility = coreDataActionsUtility
        self.title = "Locations List"
    }
    
    /// A method to load the initial list of locations
    func loadLocations() {

        self.isLoading = true
        coreDataActionsUtility.getCachedLocations { [weak self] cachedLocations in

            guard let self else { return }

            if cachedLocations.isEmpty {
                self.jsonFileReader.getModelFromJSONFile(with: "locations") { (locationsParentNode: DecodableModel.LocationsParentNode?) in

                    guard let locationsParentNode else {
                        self.locations = []
                        self.isLoading = false
                        return
                    }

                    //Convert codable locations into Location object which are recognized by the view controller
                    self.locationsListScreenLocationModels = locationsParentNode.locations.map { codableLocation -> Location in

                        let coordinates = codableLocation.coordinates

                        return Location(
                            id: codableLocation.id,
                            name: codableLocation.name,
                            coordinates: Location.Coordinates(
                                latitude: coordinates.latitude,
                                longitude: coordinates.longitude
                            )
                        )
                    }
                    self.coreDataActionsUtility.storeLocationsInCache(with: self.locationsListScreenLocationModels)
                    self.locations = self.locationsListScreenLocationModels
                    self.isLoading = false
                }
            } else {
                self.locationsListScreenLocationModels = cachedLocations
                self.locations = self.locationsListScreenLocationModels
                self.isLoading = false
            }
        }
    }

    /// A method to navigate to favorites page
    func goToFavoritesPage() {

        let favoriteLocations = self.locationsListScreenLocationModels.filter({ $0.isFavorite })

        if favoriteLocations.isEmpty {
            self.alertInfo = AlertInfo(title: "No Favorites", message: "You have not favorited any locations yet.")
        } else {

            let favoriteStatusChangedClosure: (String) -> Void = { locationId in

                if let updatedLocationIndex = self.locationsListScreenLocationModels.firstIndex(where: { $0.id == locationId }) {
                    self.cellIndexToReload = updatedLocationIndex
                }
            }

            router?.navigateToFavoritesPage(with: favoriteLocations, favoriteStatusChangedClosure: favoriteStatusChangedClosure)
        }
    }

    /// A method to toggle favorite status for the selected location
    /// - Parameter location: A location for which we need to toggle favorite status
    func toggleFavoriteStatus(for location: Location) {
        location.toggleFavoriteStatus()
        self.coreDataActionsUtility.toggleFavoriteStatusForLocation(with: location.id)
        self.loadAndCacheFavoritedLocation(location: location)
    }

    /// A method to navigate to temperature forecast details page
    /// - Parameter location: A location for which the temperature details are queried
    func goToLocationForecastDetailsPage(with location: Location) {
        self.isLoading = true

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

    private func loadAndCacheFavoritedLocation(location: Location) {

        self.isLoading = true

        guard location.isFavorite else {
            //Remove saved location info from cache
            self.coreDataActionsUtility.removeTemperatureData(for: location.id)
            self.isLoading = false
            return
        }

        self.temperatureInfoUtility.loadWeatherInformation(with: location) { result in

            self.isLoading = false

            switch result {
            case .success(let cachedLocationInfoData):
                self.coreDataActionsUtility.saveTemperatureData(
                    with: location.id,
                    currentTemperatureViewModel: cachedLocationInfoData.0,
                    temperatureForecastViewModels: cachedLocationInfoData.1
                )
            case .failure(let failure):
                if case .internetUnavailable = failure {
                    return
                }
                self.alertInfo = AlertInfo(title: "Error", message: "Failed to save favorited location temperature information in the cache. Failed with error \(failure.errorMessageString())")
            }
        }
    }
}
