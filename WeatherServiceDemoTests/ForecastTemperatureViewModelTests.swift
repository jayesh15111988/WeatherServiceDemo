//
//  ForecastTemperatureViewModelTests.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/28/23.
//

import XCTest
@testable import WeatherServiceDemo

final class ForecastTemperatureViewModelTests: XCTestCase {
    private var viewModel: ForecastTemperatureViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ForecastTemperatureViewModel(
            minimumTemperatureCelsius: 23.4,
            maximumTemperatureCelsius: 56.7,
            averageTemperatureCelsius: 123.4,
            minimumTemperatureFahrenheit: 57.8,
            maximumTemperatureFahrenheit: 9.21,
            averageTemperatureFahrenheit: 12.34,
            lastUpdatedDateString: "December 12, 2023",
            unit: .celsius
        )
    }

    func testThatViewModelCorrectlyReturnsMinimumTemperatureDisplayValue() {
        XCTAssertEqual(viewModel.minimumTemperatureDisplayValue, "Minimum Temperature: 23.4 Celsius")
        viewModel.reverseUnit()
        XCTAssertEqual(viewModel.minimumTemperatureDisplayValue, "Minimum Temperature: 57.8 Fahrenheit")
        viewModel.reverseUnit()
    }

    func testThatViewModelCorrectlyReturnsMaximumTemperatureDisplayValue() {
        XCTAssertEqual(viewModel.maximumTemperatureDisplayValue, "Maximum Temperature: 56.7 Celsius")
        viewModel.reverseUnit()
        XCTAssertEqual(viewModel.maximumTemperatureDisplayValue, "Maximum Temperature: 9.21 Fahrenheit")
        viewModel.reverseUnit()
    }

    func testThatViewModelCorrectlyReturnsAverageTemperatureDisplayValue() {
        XCTAssertEqual(viewModel.averageTemperatureDisplayValue, "Average Temperature: 123.4 Celsius")
        viewModel.reverseUnit()
        XCTAssertEqual(viewModel.averageTemperatureDisplayValue, "Average Temperature: 12.34 Fahrenheit")
        viewModel.reverseUnit()
    }

    func testThatViewModelCorrectlyReversesUnit() {
        XCTAssertEqual(viewModel.unit, .celsius)
        viewModel.reverseUnit()
        XCTAssertEqual(viewModel.unit, .fahrenheit)
        viewModel.reverseUnit()
        XCTAssertEqual(viewModel.unit, .celsius)
    }

}
