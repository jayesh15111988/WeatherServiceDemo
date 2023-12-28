//
//  CurrentTemperatureViewModelTests.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/28/23.
//

import XCTest
@testable import WeatherServiceDemo

final class CurrentTemperatureViewModelTests: XCTestCase {
    private var viewModel: CurrentTemperatureViewModel!

    override func setUp() {
        super.setUp()
        viewModel = CurrentTemperatureViewModel(temperatureCelsius: 34.56, temperatureFahrenheit: 12.89, lastUpdateDateTimeString: "December 12, 2023", unit: .celsius)
    }

    func testThatViewModelCorrectlyReturnsTemperatureDisplayValue() {
        XCTAssertEqual(viewModel.temperatureDisplayValue, "Current Temperature: 34.56 Celsius")
        viewModel.reverseUnit()
        XCTAssertEqual(viewModel.temperatureDisplayValue, "Current Temperature: 12.89 Fahrenheit")
    }

    func testThatViewModelCorrectlyReversesUnit() {
        XCTAssertEqual(viewModel.unit, .celsius)
        viewModel.reverseUnit()
        XCTAssertEqual(viewModel.unit, .fahrenheit)
        viewModel.reverseUnit()
        XCTAssertEqual(viewModel.unit, .celsius)
    }
}
