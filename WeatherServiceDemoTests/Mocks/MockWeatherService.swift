//
//  MockWeatherService.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/27/23.
//

import Foundation

import WeatherService
@testable import WeatherServiceDemo

final class MockWeatherService: WeatherServiceable {
    func forecast(with input: WeatherForecastInput, daysInFuture: Int, completion: @escaping (Result<WSWeatherData, DataLoadError>) -> Void) {
        //no-op
    }
}
