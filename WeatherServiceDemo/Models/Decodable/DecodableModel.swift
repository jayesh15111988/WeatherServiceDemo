//
//  Location.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import CoreLocation

struct DecodableModel {

    struct LocationsParentNode: Decodable {
        let listId: String
        let locations: [Location]
    }

    struct Location: Decodable {
        let id: String
        let name: String
        let coordinates: Coordinates
    }

    struct Coordinates: Decodable {
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
    }
}
