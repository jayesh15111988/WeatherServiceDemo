//
//  Location.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import CoreLocation

struct Location: Decodable {
    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
}
