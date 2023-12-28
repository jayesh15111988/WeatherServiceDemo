//
//  TemperatureDetailsScreenViewModelTests.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/28/23.
//

import XCTest
@testable import WeatherServiceDemo

final class TemperatureDetailsScreenViewModelTests: XCTestCase {

    private let testCoreDataStack = TestCoreDataStack()
    private var coreDataUtility: CoreDataOperationsUtility!
    private var temperatureInfoUtility: TemperatureInfoUtility!
    private let weatherService = MockWeatherService()

    override func setUp() {
        super.setUp()
        coreDataUtility = CoreDataOperationsUtility(coreDataStore: testCoreDataStack)
        temperatureInfoUtility = TemperatureInfoUtility(weatherService: weatherService, coreDataActionsUtility: coreDataUtility)
    }

    func testThatLocationFavoriteStatusCanBeToggled() {
        let location = Location(id: "100", name: "London", coordinates: .init(latitude: 34.56, longitude: 89.77))

        let currentTemperatureViewModel = CurrentTemperatureViewModel(temperatureCelsius: 23.45, temperatureFahrenheit: 56.78, lastUpdateDateTimeString: "December 14, 2023", unit: .celsius)

        let temperatureForecastViewModels: [ForecastTemperatureViewModel] = []

        let viewModel = TemperatureDetailsScreenViewModel(
            temperatureInfo: TemperatureInfo(
                currentTemperatureViewModel: currentTemperatureViewModel,
                temperatureForecastViewModels: temperatureForecastViewModels
            ),
            location: location,
            coreDataActionsUtility: coreDataUtility,
            temperatureInfoUtility: temperatureInfoUtility
        )
        XCTAssertFalse(viewModel.isMarkedFavorite)
        XCTAssertFalse(location.isFavorite)

        viewModel.toggleLocationFavoriteStatus()

        XCTAssertTrue(viewModel.isMarkedFavorite)
        XCTAssertTrue(location.isFavorite)

        viewModel.toggleLocationFavoriteStatus()

        XCTAssertFalse(viewModel.isMarkedFavorite)
        XCTAssertFalse(location.isFavorite)
    }

    func testThatViewModelCanToggleTemperatureUnit() {
        let location = Location(id: "100", name: "London", coordinates: .init(latitude: 34.56, longitude: 89.77))

        let currentTemperatureViewModel = CurrentTemperatureViewModel(temperatureCelsius: 23.45, temperatureFahrenheit: 56.78, lastUpdateDateTimeString: "December 14, 2023", unit: .celsius)

        let temperatureForecastViewModels: [ForecastTemperatureViewModel] = []

        let viewModel = TemperatureDetailsScreenViewModel(
            temperatureInfo: TemperatureInfo(
                currentTemperatureViewModel: currentTemperatureViewModel,
                temperatureForecastViewModels: temperatureForecastViewModels
            ),
            location: location,
            coreDataActionsUtility: coreDataUtility,
            temperatureInfoUtility: temperatureInfoUtility
        )

        XCTAssertNotNil(viewModel.unitToSectionsMapping[.celsius])
        XCTAssertNil(viewModel.unitToSectionsMapping[.fahrenheit])

        // First check if view models have celsius unit
        XCTAssertEqual(viewModel.currentTemperatureUnit, .celsius)

        XCTAssertEqual(viewModel.sections.count, 2)

        var currentSection = viewModel.sections[0]

        if case let .currentTemperature(viewModel) = currentSection {
            XCTAssertEqual(viewModel.unit, .celsius)
        } else {
            XCTFail("Unexpected first section. Expected current temperature section")
        }

        var forecastSection = viewModel.sections[1]

        if case let .forecastTemperatures(viewModels) = forecastSection {
            XCTAssertEqual(viewModels.first?.unit, .celsius)
        } else {
            XCTFail("Unexpected last section. Expected forecast temperature section")
        }

        // Now toggle the unit check if view models have Fahrenheit unit
        viewModel.toggleTemperatureUnit(newTemperatureUnit: .fahrenheit)
        XCTAssertEqual(viewModel.currentTemperatureUnit, .fahrenheit)
        XCTAssertEqual(viewModel.sections.count, 2)

        XCTAssertNotNil(viewModel.unitToSectionsMapping[.celsius])
        XCTAssertNotNil(viewModel.unitToSectionsMapping[.fahrenheit])

        currentSection = viewModel.sections[0]

        if case let .currentTemperature(viewModel) = currentSection {
            XCTAssertEqual(viewModel.unit, .fahrenheit)
        } else {
            XCTFail("Unexpected first section. Expected current temperature section")
        }

        forecastSection = viewModel.sections[1]

        if case let .forecastTemperatures(viewModels) = forecastSection {
            XCTAssertEqual(viewModels.first?.unit, .fahrenheit)
        } else {
            XCTFail("Unexpected last section. Expected forecast temperature section")
        }

        // Now toggle again and check if the view models have Celsius unit again
        viewModel.toggleTemperatureUnit(newTemperatureUnit: .celsius)
        XCTAssertEqual(viewModel.currentTemperatureUnit, .celsius)
        XCTAssertEqual(viewModel.sections.count, 2)

        currentSection = viewModel.sections[0]

        if case let .currentTemperature(viewModel) = currentSection {
            XCTAssertEqual(viewModel.unit, .celsius)
        } else {
            XCTFail("Unexpected first section. Expected current temperature section")
        }

        XCTAssertNotNil(viewModel.unitToSectionsMapping[.celsius])
        XCTAssertNotNil(viewModel.unitToSectionsMapping[.fahrenheit])

        forecastSection = viewModel.sections[1]

        if case let .forecastTemperatures(viewModels) = forecastSection {
            XCTAssertEqual(viewModels.first?.unit, .celsius)
        } else {
            XCTFail("Unexpected last section. Expected forecast temperature section")
        }
    }
}
