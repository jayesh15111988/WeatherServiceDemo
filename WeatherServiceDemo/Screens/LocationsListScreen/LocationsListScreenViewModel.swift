//
//  LocationsListScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import CoreLocation
import Foundation

final class LocationsListScreenViewModel {

    weak var view: LocationsListScreenViewable?
    var router: LocationsListScreenRouter?

    let jsonFileReader: JSONFileReadable

    init(jsonFileReader: JSONFileReadable) {
        self.jsonFileReader = jsonFileReader
    }

    func loadLocations() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let locationsParentNode: DecodableModel.LocationsParentNode = jsonFileReader.getModelFromJSONFile(with: "locations") else {
                self.view?.reloadView(with: [])
                return
            }

            let locationsListScreenLocationModels: [LocationsListScreenViewModel.Location] = locationsParentNode.locations.map { codableLocation -> LocationsListScreenViewModel.Location in

                let coordinates = codableLocation.coordinates

                return LocationsListScreenViewModel.Location(
                    id: codableLocation.id,
                    name: codableLocation.name,
                    coordinates: Location.Coordinates(
                        latitude: coordinates.latitude,
                        longitude: coordinates.longitude
                    )
                )
            }

            DispatchQueue.main.async {
                self.view?.reloadView(with: locationsListScreenLocationModels)
            }
        }
    }
}

extension LocationsListScreenViewModel {

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

        struct Coordinates {
            let latitude: CLLocationDegrees
            let longitude: CLLocationDegrees
        }

        func toggleFavoriteStatus() {
            isFavorite = !isFavorite
        }
    }
}
