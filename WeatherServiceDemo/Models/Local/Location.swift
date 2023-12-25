//
//  Location.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/22/23.
//

import UIKit
import CoreLocation

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
