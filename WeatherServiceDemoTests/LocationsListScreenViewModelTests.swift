//
//  LocationsListScreenViewModelTests.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/27/23.
//

import XCTest
@testable import WeatherServiceDemo

final class LocationsListScreenViewModelTests: XCTestCase {
    
    private var testCoreDataStack = TestCoreDataStack()
    private var coreDataUtility: CoreDataOperationsUtility!
    private var temperatureInfoUtility: TemperatureInfoUtility!
    private let weatherService = MockWeatherService()
    private let jsonFileReader = MockJSONFileReader()

    override func setUp() {
        super.setUp()
        coreDataUtility = CoreDataOperationsUtility(coreDataStore: testCoreDataStack)
        temperatureInfoUtility = TemperatureInfoUtility(weatherService: weatherService, coreDataActionsUtility: coreDataUtility)
    }

    func testThatFavoriteStatusOfLocationCanBeToggled() {
        let viewModel = LocationsListScreenViewModel(jsonFileReader: jsonFileReader, temperatureInfoUtility: temperatureInfoUtility, coreDataActionsUtility: coreDataUtility)

        let sourceLocation = Location(id: "100", name: "Boston", coordinates: .init(latitude: 23.4, longitude: 56.7))

        XCTAssertFalse(sourceLocation.isFavorite)
        viewModel.toggleFavoriteStatus(for: sourceLocation)
        XCTAssertTrue(sourceLocation.isFavorite)
        viewModel.toggleFavoriteStatus(for: sourceLocation)
        XCTAssertFalse(sourceLocation.isFavorite)
    }

    func testThatLocationsCanBeStoreAndRetrievedFromCache() {
        let viewModel = LocationsListScreenViewModel(jsonFileReader: jsonFileReader, temperatureInfoUtility: temperatureInfoUtility, coreDataActionsUtility: coreDataUtility)

        viewModel.loadLocations()

        Thread.sleep(forTimeInterval: 3)

        viewModel.loadLocations()

        Thread.sleep(forTimeInterval: 3)
        print("")
    }
}
