//
//  FavoriteLocationsListScreenViewModelTests.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/27/23.
//

import Combine
import XCTest
@testable import WeatherServiceDemo

final class FavoriteLocationsListScreenViewModelTests: XCTestCase {
    
    private let testCoreDataStack = TestCoreDataStack()
    private var coreDataUtility: CoreDataOperationsUtility!
    private var temperatureInfoUtility: TemperatureInfoUtility!
    private let weatherService = MockWeatherService()
    private var subscriptions: [AnyCancellable] = []

    override func setUp() {
        super.setUp()
        coreDataUtility = CoreDataOperationsUtility(coreDataStore: testCoreDataStack)
        temperatureInfoUtility = TemperatureInfoUtility(weatherService: weatherService, coreDataActionsUtility: coreDataUtility)
    }

    func testThatFavoriteLocationIsSuccessfullyRemovedFromFavoritesList() {

        let expectation = XCTestExpectation(description: "Location unfavorite action should successfully happen")

        let favoriteLocations: [Location] = [Location(id: "100", name: "London", coordinates: .init(latitude: 23.4, longitude: 56.3))]

        var removedFavoriteLocationId: String?
        var shownAlertInfo: AlertInfo?

        let favoriteLocationsListScreenViewModel = FavoriteLocationsListScreenViewModel(
            favoriteLocationModels: favoriteLocations,
            temperatureInfoUtility: temperatureInfoUtility,
            coreDataOperationsUtility: coreDataUtility) { favoriteLocationId in
            removedFavoriteLocationId = favoriteLocationId
        }

        favoriteLocationsListScreenViewModel.$alertInfo.compactMap { $0 }.sink { alertInfo in
            shownAlertInfo = alertInfo
            expectation.fulfill()
        }.store(in: &subscriptions)

        favoriteLocationsListScreenViewModel.removeLocationFromFavorites(at: 0)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(favoriteLocationsListScreenViewModel.favoriteLocationModels.isEmpty)
        XCTAssertEqual(removedFavoriteLocationId, "100")
        XCTAssertEqual(shownAlertInfo?.title, "No Favorites")
        XCTAssertEqual(shownAlertInfo?.message, "You don't have any favorites. Please click on star icon to add location to favorites list")
    }

    func testThatViewModelTitleIsSetCorrectly() {

        let favoriteLocationsListScreenViewModel = FavoriteLocationsListScreenViewModel(
            favoriteLocationModels: [],
            temperatureInfoUtility: temperatureInfoUtility,
            coreDataOperationsUtility: coreDataUtility) { favoriteLocationId in
                //no-op
            }

        XCTAssertEqual(viewModel.title, "Favorites")
    }
}
