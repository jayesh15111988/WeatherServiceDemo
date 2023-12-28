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
    private let weatherService = MockWeatherService()
    private var coreDataUtility: CoreDataOperationsUtility!
    private let jsonFileReader = MockJSONFileReader()
    private var viewModel: LocationsListScreenViewModel!

    override func setUp() {
        super.setUp()
        coreDataUtility = CoreDataOperationsUtility(coreDataStore: testCoreDataStack)
        let temperatureInfoUtility = TemperatureInfoUtility(weatherService: weatherService, coreDataActionsUtility: coreDataUtility)
        viewModel = LocationsListScreenViewModel(jsonFileReader: jsonFileReader, temperatureInfoUtility: temperatureInfoUtility, coreDataActionsUtility: coreDataUtility)
    }

    func testThatFavoriteStatusOfLocationCanBeToggled() {

        let sourceLocation = Location(id: "100", name: "Boston", coordinates: .init(latitude: 23.4, longitude: 56.7))

        XCTAssertFalse(sourceLocation.isFavorite)
        viewModel.toggleFavoriteStatus(for: sourceLocation)
        XCTAssertTrue(sourceLocation.isFavorite)
        viewModel.toggleFavoriteStatus(for: sourceLocation)
        XCTAssertFalse(sourceLocation.isFavorite)
    }

    func testThatLocationsCanBeStoreAndRetrievedFromCache() {

        var cachedLocations = coreDataUtility.locationsListFromCache(with: testCoreDataStack.context)

        XCTAssertTrue(cachedLocations.isEmpty)

        viewModel.loadLocations()

        cachedLocations = coreDataUtility.locationsListFromCache(with: testCoreDataStack.context)
        XCTAssertFalse(cachedLocations.isEmpty)

        let viewModelLocations = viewModel.locations

        XCTAssertFalse(viewModelLocations.isEmpty)

        let firstLocation = viewModelLocations.first!
        XCTAssertEqual(firstLocation.id, "1")
        XCTAssertEqual(firstLocation.name, "London, United Kingdom")
        XCTAssertEqual(firstLocation.coordinates.longitude, 0.1278)
        XCTAssertEqual(firstLocation.coordinates.latitude, 51.5074)
        XCTAssertFalse(firstLocation.isFavorite)

        let lastLocation = viewModelLocations.last!
        XCTAssertEqual(lastLocation.id, "9")
        XCTAssertEqual(lastLocation.name, "Budapest, Hungary")
        XCTAssertEqual(lastLocation.coordinates.longitude, 19.0402)
        XCTAssertEqual(lastLocation.coordinates.latitude, 47.4979)
        XCTAssertFalse(lastLocation.isFavorite)
    }

    func testThatViewModelTitleIsSetCorrectly() {
        XCTAssertEqual(viewModel.title, "Locations List")
    }
}
