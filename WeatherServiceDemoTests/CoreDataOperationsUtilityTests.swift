//
//  CoreDataOperationsUtilityTests.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/28/23.
//

import XCTest
@testable import WeatherServiceDemo

final class CoreDataOperationsUtilityTests: XCTestCase {

    private var testCoreDataStack = TestCoreDataStack()
    private var coreDataOperationsUtility: CoreDataOperationsUtility!

    override func setUp() {
        super.setUp()
        coreDataOperationsUtility = CoreDataOperationsUtility(coreDataStore: testCoreDataStack)
    }

    func testThatLocationsAreSuccessfullyCached() {

        let expectation = XCTestExpectation(description: "Locations are successfully cached")

        let location = Location(id: "100", name: "Boston", coordinates: .init(latitude: 23.45, longitude: 33.11))
        location.toggleFavoriteStatus()
        coreDataOperationsUtility.storeLocationsInCache(with: [location])

        coreDataOperationsUtility.getCachedLocations { locations in
            let location = locations.first
            XCTAssertEqual(location?.id, "100")
            XCTAssertEqual(location?.name, "Boston")
            XCTAssertEqual(location?.coordinates.latitude, 23.45)
            XCTAssertEqual(location?.coordinates.longitude, 33.11)
            XCTAssertEqual(location?.isFavorite, true)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testThatTemperatureInfoCanBeSuccessfullySavedAndRemovedFromDatabase() {

        let currentTemperatureViewModel = CurrentTemperatureViewModel(temperatureCelsius: 23.45, temperatureFahrenheit: 56.78, lastUpdateDateTimeString: "December 14, 2023", unit: .celsius)

        let temperatureForecastViewModels: [ForecastTemperatureViewModel] = [ForecastTemperatureViewModel(minimumTemperatureCelsius: 12.34, maximumTemperatureCelsius: 78.9, averageTemperatureCelsius: 34.11, minimumTemperatureFahrenheit: 33.44, maximumTemperatureFahrenheit: 66.78, averageTemperatureFahrenheit: 90.8, lastUpdatedDateString: "December 12, 2023", unit: .celsius)]


        coreDataOperationsUtility.saveTemperatureData(with: "200", currentTemperatureViewModel: currentTemperatureViewModel, temperatureForecastViewModels: temperatureForecastViewModels)

        let expectation = XCTestExpectation(description: "Temperature details can be stored and retrieved from local database")

        coreDataOperationsUtility.getCachedTemperatureInformation(with: Location(id: "200", name: "Boston", coordinates: .init(latitude: 34.56, longitude: 11.11))) { currentTemperatureViewModel, forecastTemperatureViewModels in
            
            XCTAssertEqual(currentTemperatureViewModel?.lastUpdateDateTimeString, "December 14, 2023")
                           XCTAssertEqual(currentTemperatureViewModel?.temperatureCelsius, 23.45)
            XCTAssertEqual(currentTemperatureViewModel?.temperatureDisplayValue, "Current Temperature: 23.45 Celsius")

            let forecastTemperatureViewModel = forecastTemperatureViewModels?.first

                           XCTAssertEqual(forecastTemperatureViewModel?.averageTemperatureCelsius, 34.11)
                           XCTAssertEqual(forecastTemperatureViewModel?.maximumTemperatureCelsius, 78.9)
            XCTAssertEqual(forecastTemperatureViewModel?.maximumTemperatureDisplayValue, "Maximum Temperature: 78.9 Celsius")

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        let removeCachedTemperatureInfoExpectation = XCTestExpectation(description: "Cached temperature data is successfully removed from local cache")

        coreDataOperationsUtility.removeTemperatureData(for: "200")

        coreDataOperationsUtility.getCachedTemperatureInformation(with: Location(id: "200", name: "Boston", coordinates: .init(latitude: 34.56, longitude: 11.11))) { currentTemperatureViewModel, forecastTemperatureViewModels in
            XCTAssertNil(currentTemperatureViewModel)
            XCTAssertNil(forecastTemperatureViewModels)
            removeCachedTemperatureInfoExpectation.fulfill()
        }

        wait(for: [removeCachedTemperatureInfoExpectation], timeout: 2.0)
    }
}
