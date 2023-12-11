//
//  TemperatureDetailsScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

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
}

final class TemperatureDetailsScreenViewModel {

    var router: TemperatureDetailsScreenRouter?
    weak var view: TemperatureDetailsScreenViewable?

    private let temperatureInfo: TemperatureInfo
    let location: Location
    private let coreDataActionsUtility: CoreDataActionsUtility
    private let temperatureInfoUtility: TemperatureInfoUtility
    let sections: [Section]

    var title: String {
        return location.name
    }

    init(
        temperatureInfo: TemperatureInfo,
        location: Location,
        coreDataActionsUtility: CoreDataActionsUtility = CoreDataActionsUtility(),
        temperatureInfoUtility: TemperatureInfoUtility) {
        self.temperatureInfo = temperatureInfo
        self.location = location
        self.coreDataActionsUtility = coreDataActionsUtility
        self.temperatureInfoUtility = temperatureInfoUtility
            self.sections = [.currentTemperature(viewModel: temperatureInfo.currentTemperatureViewModel), .forecastTemperatures(viewModels: temperatureInfo.temperatureForecastViewModels)]
    }
    
    /// A method to toggle favorite status of current location on the favorites screen
    func toggleLocationFavoriteStatus() {

        self.view?.showLoadingIndicator(true)

        // Toggle locations's favorite status
        location.toggleFavoriteStatus()

        // If location is unfavorited, just remove it from cache
        if !location.isFavorite {
            self.temperatureInfoUtility.removeTemperatureData(for: location.id)
        } else {
            // If the location is newly favorited, add it to the cache
            self.temperatureInfoUtility.saveTemperatureData(
                with: self.location.id,
                currentTemperatureViewModel: temperatureInfo.currentTemperatureViewModel,
                temperatureForecastViewModels: temperatureInfo.temperatureForecastViewModels
            )
        }

        // Update the location's favorite status in the local cache
        self.coreDataActionsUtility.toggleFavoriteStatusForLocation(with: location.id)
        view?.updateFavoriteLocationIcon(location.isFavorite)
        self.view?.showLoadingIndicator(false)
    }
}

struct CurrentTemperatureViewModel {
    let temperatureCelsius: Double
    let temperatureFahrenheit: Double
    let lastUpdateDateTimeString: String
    let unit: TemperatureUnit

    var temperatureDisplayValue: String {
        switch unit {
        case .celsius:
            return "Current Temperature: \(temperatureCelsius) \(unit.displayTitle)"
        case .fahrenheit:
            return "Current Temperature: \(temperatureFahrenheit) \(unit.displayTitle)"
        }
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
    let unit: TemperatureUnit

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
}

enum TemperatureUnit {
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

