//
//  SectionsTests.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/28/23.
//

import XCTest
@testable import WeatherServiceDemo

final class SectionsTests: XCTestCase {
    
    private let currentTemperatureSection = Section.currentTemperature(viewModel: CurrentTemperatureViewModel(temperatureCelsius: 12.34, temperatureFahrenheit: 67.89, lastUpdateDateTimeString: "December 18, 2023", unit: .celsius))

    private let forecastTemperatureSection = Section.forecastTemperatures(viewModels: [ForecastTemperatureViewModel(minimumTemperatureCelsius: 12.34, maximumTemperatureCelsius: 78.9, averageTemperatureCelsius: 34.11, minimumTemperatureFahrenheit: 33.44, maximumTemperatureFahrenheit: 66.78, averageTemperatureFahrenheit: 90.8, lastUpdatedDateString: "December 12, 2023", unit: .celsius)])

    func testThatSectionReturnsCorrectSectionTitle() {
        XCTAssertEqual(currentTemperatureSection.title, "Current Temperature")
        XCTAssertEqual(forecastTemperatureSection.title, "Forecast")
    }

    func testThatSectionReturnsCorrectRowCount() {
        XCTAssertEqual(currentTemperatureSection.rowCount, 1)
        XCTAssertEqual(forecastTemperatureSection.rowCount, 1)
    }
}
