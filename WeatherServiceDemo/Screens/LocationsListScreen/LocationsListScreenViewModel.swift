//
//  LocationsListScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import CoreLocation
import UIKit

final class LocationsListScreenViewModel {

    weak var view: LocationsListScreenViewable?
    var router: LocationsListScreenRouter?

    private var locationsListScreenLocationModels: [Location] = []
    let jsonFileReader: JSONFileReadable
    let title: String

    init(jsonFileReader: JSONFileReadable) {
        self.jsonFileReader = jsonFileReader
        self.title = "Locations List"
    }

    func loadLocations() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let locationsParentNode: DecodableModel.LocationsParentNode = self.jsonFileReader.getModelFromJSONFile(with: "locations") else {
                self.view?.reloadView(with: [])
                return
            }

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

            DispatchQueue.main.async {
                self.view?.reloadView(with: self.locationsListScreenLocationModels)
            }
        }
    }

    func goToFavoritesPage() {
        let favoriteLocations = self.locationsListScreenLocationModels.filter({ $0.isFavorite })

        if favoriteLocations.isEmpty {
            self.view?.showAlert(with: "No Favorites", message: "You have not favorited any locations yet.")
        } else {
            router?.navigateToFavoritesPage(with: favoriteLocations)
        }
    }

    func goToLocationForecastDetailsPage(with location: Location) {
        self.router?.navigateToLocationForecastDetailsPage(with: location)
    }
}

final class Location {
    let id: String
    let name: String
    let coordinates: Coordinates
    private(set)var isFavorite: Bool

    init(id: String, name: String, coordinates: Coordinates, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.coordinates = coordinates
        self.isFavorite = isFavorite
    }

    var favoritesImage: UIImage? {
        return self.isFavorite ? Style.shared.favoriteImage : Style.shared.nonFavoriteImage
    }

    struct Coordinates {
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
    }

    func toggleFavoriteStatus() {
        isFavorite = !isFavorite
    }
}
