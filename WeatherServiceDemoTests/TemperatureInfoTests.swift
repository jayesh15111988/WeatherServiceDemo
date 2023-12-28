//
//  TemperatureInfoTests.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/28/23.
//

import XCTest
@testable import WeatherServiceDemo

final class TemperatureInfoTests: XCTestCase {

    func testThatViewModelReturnsCorrectCurrentTemperatureUnit() {

        let currentTemperatureViewModel = CurrentTemperatureViewModel(temperatureCelsius: 23.45, temperatureFahrenheit: 56.78, lastUpdateDateTimeString: "December 14, 2023", unit: .celsius)

        let temperatureForecastViewModels: [ForecastTemperatureViewModel] = []

        let temperatureInfo = TemperatureInfo(currentTemperatureViewModel: currentTemperatureViewModel, temperatureForecastViewModels: temperatureForecastViewModels)
        XCTAssertEqual(temperatureInfo.currentTemperatureUnit, .celsius)
    }
}
