//
//  TemperatureDetailsScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import Foundation
import WeatherService

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

final class TemperatureDetailsScreenViewModel {

    var router: TemperatureDetailsScreenRouter?
    weak var view: TemperatureDetailsScreenViewable?

    var title: String {
        return location.name
    }

    private let location: Location
    private let weatherService: WeatherService
    private let coreDataActionsUtility: CoreDataActionsUtility

    init(location: Location, weatherService: WeatherService, coreDataActionsUtility: CoreDataActionsUtility = CoreDataActionsUtility()) {
        self.location = location
        self.weatherService = weatherService
        self.coreDataActionsUtility = coreDataActionsUtility
    }

    func loadAndStoreForecastDetailsForCurrentLocation() {
        let coordinates = location.coordinates
        self.weatherService.forecastAndCurrentTemperature(for: .coordinates(latitude: coordinates.latitude, longitude: coordinates.longitude)) { [weak self] result in

            guard let self else { return }

            switch result {
            case .success(let weatherData):

                let sections = self.convertRemoteWeatherDataToSections(with: weatherData)

                DispatchQueue.main.async {
                    self.view?.refreshView(with: sections)
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self.view?.showAlert(with: "Error", message: failure.errorMessageString())
                }
            }
        }
    }

    private func convertRemoteWeatherDataToSections(with weatherData: WSWeatherData) -> [Section] {

        let currentTemperatureViewModel = CurrentTemperatureViewModel(
            temperatureCelsius: weatherData.currentTemperature.temperatureCelsius,
            temperatureFahrenheit: weatherData.currentTemperature.temperatureFahrenheit,
            lastUpdateDateTimeString: "Last Updated : \(weatherData.currentTemperature.lastUpdateDateTimeString)",
            unit: .celsius
        )

        let currentTemperatureSection = Section.currentTemperature(
            viewModel: currentTemperatureViewModel
        )

        let forecastTemperatureViewModels: [ForecastTemperatureViewModel] = weatherData.forecasts.map { forecast -> ForecastTemperatureViewModel in
            return ForecastTemperatureViewModel(
                minimumTemperatureCelsius: forecast.minimumTemperatureCelsius,
                maximumTemperatureCelsius: forecast.maximumTemperatureCelsius,
                averageTemperatureCelsius: forecast.averageTemperatureCelsius,
                minimumTemperatureFahrenheit: forecast.minimumTemperatureFahrenheit,
                maximumTemperatureFahrenheit: forecast.maximumTemperatureFahrenheit,
                averageTemperatureFahrenheit: forecast.averageTemperatureFahrenheit,
                lastUpdatedDateString: "Forecast for: \(forecast.dateString)",
                unit: .celsius
            )
        }

        let sections = [
            currentTemperatureSection,
                .forecastTemperatures(viewModels: forecastTemperatureViewModels)
        ]
        coreDataActionsUtility.saveTemperatureData(
            with: location.id,
            currentTemperatureViewModel: currentTemperatureViewModel,
            temperatureForecastViewModels: forecastTemperatureViewModels
        )
        return sections
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

