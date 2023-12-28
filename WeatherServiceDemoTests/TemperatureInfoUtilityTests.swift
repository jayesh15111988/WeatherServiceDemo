//
//  TemperatureInfoUtilityTests.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/28/23.
//

import XCTest
@testable import WeatherServiceDemo
@testable import WeatherService

final class TemperatureInfoUtilityTests: XCTestCase {

    private var testCoreDataStack = TestCoreDataStack()
    private let weatherService = MockWeatherService()
    private var coreDataUtility: CoreDataOperationsUtility!
    private var temperatureInfoUtility: TemperatureInfoUtility!

    override func setUp() {
        super.setUp()
        coreDataUtility = CoreDataOperationsUtility(coreDataStore: testCoreDataStack)
        temperatureInfoUtility = TemperatureInfoUtility(weatherService: weatherService, coreDataActionsUtility: coreDataUtility)
    }

    func testThatUtilitySuccessfullyConvertsRemoteWeatherDataToLocalViewModels() {

        let location: WSWeatherData.Location = .init(name: "Boston", country: "USA")

        let forecasts: [WSWeatherData.Forecast] = [.init(dateTimestamp: 41423424, dateString: "December 14, 2023", maximumTemperatureCelsius: 44.5, maximumTemperatureFahrenheit: 12.1, minimumTemperatureCelsius: 33.3, minimumTemperatureFahrenheit: 78.5, averageTemperatureCelsius: 100.0, averageTemperatureFahrenheit: 11.99)]

        let currentWeatherData = WSCurrent(temperatureCelsius: 34.5, temperatureFahrenheit: 33.33, lastUpdateDateTimestamp: 244243, lastUpdateDateTimeString: "September 13th, 2023")

        let weatherData = WSWeatherData(location: location, current: currentWeatherData, forecasts: forecasts)

        let weatherViewModels = temperatureInfoUtility.convertRemoteWeatherDataToLocalViewModels(with: weatherData, location: .init(id: "100", name: "Boston", coordinates: .init(latitude: 100.2, longitude: 67.3)))

        let currentTemperatureViewModel = weatherViewModels.currentTemperatureViewModel
        XCTAssertEqual(currentTemperatureViewModel.temperatureCelsius, 34.5)
        XCTAssertEqual(currentTemperatureViewModel.temperatureFahrenheit, 33.33)
        XCTAssertEqual(currentTemperatureViewModel.lastUpdateDateTimeString, "Last Updated : September 13th, 2023")
        XCTAssertEqual(currentTemperatureViewModel.unit, .celsius)

        let forecastTemperatureViewModel = weatherViewModels.forecastTemperatureViewModels.first

        XCTAssertEqual(forecastTemperatureViewModel?.minimumTemperatureCelsius, 33.3)
        XCTAssertEqual(forecastTemperatureViewModel?.maximumTemperatureCelsius, 44.5)
        XCTAssertEqual(forecastTemperatureViewModel?.averageTemperatureCelsius, 100.0)
        XCTAssertEqual(forecastTemperatureViewModel?.minimumTemperatureFahrenheit, 78.5)
        XCTAssertEqual(forecastTemperatureViewModel?.maximumTemperatureFahrenheit, 12.1)
        XCTAssertEqual(forecastTemperatureViewModel?.averageTemperatureFahrenheit, 11.99)
        XCTAssertEqual(forecastTemperatureViewModel?.lastUpdatedDateString, "Forecast for: December 14, 2023")
        XCTAssertEqual(forecastTemperatureViewModel?.unit, .celsius)
    }
}
