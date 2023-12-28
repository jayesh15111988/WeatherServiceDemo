//
//  TemperatureDetailsScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import Combine
import Foundation

import WeatherService

/// Table view sections to show current and forecast temperatures in different sections
enum Section {
    case currentTemperature(viewModel: CurrentTemperatureViewModel)
    case forecastTemperatures(viewModels: [ForecastTemperatureViewModel])

    var title: String {
        switch self {
        case .currentTemperature:
            return "Current Temperature"
        case .forecastTemperatures:
            return "Forecast"
        }
    }

    var rowCount: Int {
        switch self {
        case .currentTemperature:
            return 1
        case .forecastTemperatures(let viewModels):
            return viewModels.count
        }
    }
}

/// A struct to store current temperature and forecast temperature info in a single container
struct TemperatureInfo {
    let currentTemperatureViewModel: CurrentTemperatureViewModel
    let temperatureForecastViewModels: [ForecastTemperatureViewModel]

    var currentTemperatureUnit: TemperatureUnit {
        return currentTemperatureViewModel.unit
    }
}

final class TemperatureDetailsScreenViewModel {

    var router: TemperatureDetailsScreenRouter?

    private let temperatureInfo: TemperatureInfo
    let location: Location
    private let coreDataActionsUtility: CoreDataOperationsUtility
    private let temperatureInfoUtility: TemperatureInfoUtility
    private(set) var sections: [Section]

    @Published var isLoading = false
    @Published var reloadTableView = false
    @Published var isMarkedFavorite = false

    var title: String {
        return location.name
    }

    var unitToSectionsMapping: [TemperatureUnit: [Section]] = [:]

    private(set) var currentTemperatureUnit: TemperatureUnit

    init(
        temperatureInfo: TemperatureInfo,
        location: Location,
        coreDataActionsUtility: CoreDataOperationsUtility,
        temperatureInfoUtility: TemperatureInfoUtility) {
        self.temperatureInfo = temperatureInfo
        self.location = location
        self.coreDataActionsUtility = coreDataActionsUtility
        self.temperatureInfoUtility = temperatureInfoUtility
        self.sections = [
            .currentTemperature(
                viewModel: temperatureInfo.currentTemperatureViewModel
            ),
                .forecastTemperatures(
                    viewModels: temperatureInfo.temperatureForecastViewModels
                )
        ]
        currentTemperatureUnit = temperatureInfo.currentTemperatureUnit
        // Since default unit is celsius, we will use .celsius as an enum value to store sections in the dictionary
        unitToSectionsMapping[self.temperatureInfo.currentTemperatureUnit] = self.sections
        reloadTableView = true
        self.isMarkedFavorite = location.isFavorite
    }
    
    /// A method to toggle favorite status of current location on the favorites screen
    func toggleLocationFavoriteStatus() {

        self.isLoading = true

        // Toggle locations's favorite status
        location.toggleFavoriteStatus()

        // If location is unfavorited, just remove it from cache
        if !location.isFavorite {
            self.coreDataActionsUtility.removeTemperatureData(for: location.id)
        } else {
            // If the location is newly favorited, add it to the cache
            self.coreDataActionsUtility.saveTemperatureData(
                with: self.location.id,
                currentTemperatureViewModel: temperatureInfo.currentTemperatureViewModel,
                temperatureForecastViewModels: temperatureInfo.temperatureForecastViewModels
            )
        }

        // Update the location's favorite status in the local cache
        self.coreDataActionsUtility.toggleFavoriteStatusForLocation(with: location.id)
        self.isMarkedFavorite = location.isFavorite
        self.isLoading = false
    }

    //A function to toggle temperature units based on the user input
    func toggleTemperatureUnit(newTemperatureUnit: TemperatureUnit) {

        //If current and new temperature units are same, we don't need to do anything
        guard currentTemperatureUnit != newTemperatureUnit else {
            return
        }

        //Check if sections for new mapping already exist in the dictionary
        let newSections = unitToSectionsMapping[newTemperatureUnit]

        if let newSections {
            self.sections = newSections
        } else {

            let currentTemperatureViewModel = self.temperatureInfo.currentTemperatureViewModel

            let newCurrentTemperatureViewModel = CurrentTemperatureViewModel(
                temperatureCelsius: currentTemperatureViewModel.temperatureCelsius,
                temperatureFahrenheit: currentTemperatureViewModel.temperatureFahrenheit,
                lastUpdateDateTimeString: currentTemperatureViewModel.lastUpdateDateTimeString,
                unit: newTemperatureUnit
            )

            let currentTemperatureForecastViewModels = self.temperatureInfo.temperatureForecastViewModels

            let newTemperatureForecastViewModels: [ForecastTemperatureViewModel] = currentTemperatureForecastViewModels.map {
                return ForecastTemperatureViewModel(minimumTemperatureCelsius: $0.minimumTemperatureCelsius, maximumTemperatureCelsius: $0.maximumTemperatureCelsius, averageTemperatureCelsius: $0.averageTemperatureCelsius, minimumTemperatureFahrenheit: $0.minimumTemperatureFahrenheit, maximumTemperatureFahrenheit: $0.maximumTemperatureFahrenheit, averageTemperatureFahrenheit: $0.averageTemperatureFahrenheit, lastUpdatedDateString: $0.lastUpdatedDateString, unit: newTemperatureUnit)
            }

            //Create new sections for new temperature unit
            let newSections: [Section] = [.currentTemperature(viewModel: newCurrentTemperatureViewModel), .forecastTemperatures(viewModels: newTemperatureForecastViewModels)]

            //Perform mapping
            unitToSectionsMapping[newTemperatureUnit] = newSections

            //Set sections
            self.sections = newSections
        }
        self.reloadTableView = true
        self.currentTemperatureUnit = newTemperatureUnit
    }
}

struct CurrentTemperatureViewModel {
    let temperatureCelsius: Double
    let temperatureFahrenheit: Double
    let lastUpdateDateTimeString: String
    private(set) var unit: TemperatureUnit

    var temperatureDisplayValue: String {
        switch unit {
        case .celsius:
            return "Current Temperature: \(temperatureCelsius) \(unit.displayTitle)"
        case .fahrenheit:
            return "Current Temperature: \(temperatureFahrenheit) \(unit.displayTitle)"
        }
    }

    mutating func reverseUnit() {
        self.unit = self.unit == .celsius ? .fahrenheit : .celsius
    }
}

struct ForecastTemperatureViewModel {
    
    let minimumTemperatureCelsius: Double
    let maximumTemperatureCelsius: Double
    let averageTemperatureCelsius: Double

    let minimumTemperatureFahrenheit: Double
    let maximumTemperatureFahrenheit: Double
    let averageTemperatureFahrenheit: Double

    let lastUpdatedDateString: String
    private(set) var unit: TemperatureUnit

    var minimumTemperatureDisplayValue: String {
        switch unit {
        case .celsius:
            return "Minimum Temperature: \(minimumTemperatureCelsius) \(unit.displayTitle)"
        case .fahrenheit:
            return "Minimum Temperature: \(minimumTemperatureFahrenheit) \(unit.displayTitle)"
        }
    }

    var maximumTemperatureDisplayValue: String {
        switch unit {
        case .celsius:
            return "Maximum Temperature: \(maximumTemperatureCelsius) \(unit.displayTitle)"
        case .fahrenheit:
            return "Maximum Temperature: \(maximumTemperatureFahrenheit) \(unit.displayTitle)"
        }
    }

    var averageTemperatureDisplayValue: String {
        switch unit {
        case .celsius:
            return "Average Temperature: \(averageTemperatureCelsius) \(unit.displayTitle)"
        case .fahrenheit:
            return "Average Temperature: \(averageTemperatureFahrenheit) \(unit.displayTitle)"
        }
    }

    mutating func reverseUnit() {
        self.unit = self.unit == .celsius ? .fahrenheit : .celsius
    }
}

enum TemperatureUnit: Int {
    case celsius
    case fahrenheit

    var displayTitle: String {
        switch self {
        case .celsius:
            return "Celsius"
        case .fahrenheit:
            return "Fahrenheit"
        }
    }
}

