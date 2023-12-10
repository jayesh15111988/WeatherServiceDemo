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

    init(location: Location, weatherService: WeatherService) {
        self.location = location
        self.weatherService = weatherService
    }

    func loadForecastDetailsForCurrentLocation() {
        let coordinates = location.coordinates
        self.weatherService.forecastAndCurrentTemperature(for: .coordinates(latitude: coordinates.latitude, longitude: coordinates.longitude)) { [weak self] result in

            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self.convertRemoteWeatherDataToSections(with: weatherData)
                case .failure(let failure):
                    self.view?.showAlert(with: "Error", message: failure.errorMessageString())
                }
            }
        }
    }

    private func convertRemoteWeatherDataToSections(with weatherData: WSWeatherData) {
        let currentTemperatureSection = Section.currentTemperature(
            viewModel: CurrentTemperatureViewModel(
                temperature: weatherData.currentTemperature.temperatureCelsius,
                lastUpdateDateTimeString: "Last Updated : \(weatherData.currentTemperature.lastUpdateDateTimeString)",
                unit: .celsius)
        )

        let forecastTemperatureViewModels: [ForecastTemperatureViewModel] = weatherData.forecasts.map { forecast -> ForecastTemperatureViewModel in
            return ForecastTemperatureViewModel(
                minimumTemperature: forecast.minimumTemperatureCelsius,
                maximumTemperature: forecast.maximumTemperatureCelsius,
                averageTemperature: forecast.averageTemperatureCelsius,
                lastUpdatedDateString: "Forecast for: \(forecast.dateString)",
                unit: .celsius
            )
        }

        let sections = [
            currentTemperatureSection,
                .forecastTemperatures(viewModels: forecastTemperatureViewModels)
        ]
        self.view?.refreshView(with: sections)
    }
}

struct CurrentTemperatureViewModel {
    let temperature: Double
    let lastUpdateDateTimeString: String
    let unit: TemperatureUnit

    var temperatureDisplayValue: String {
        return "Current Temperature: \(temperature) \(unit.displayTitle)"
    }
}

struct ForecastTemperatureViewModel {
    let minimumTemperature: Double
    let maximumTemperature: Double
    let averageTemperature: Double
    let lastUpdatedDateString: String
    let unit: TemperatureUnit

    var minimumTemperatureDisplayValue: String {
        return "Minimum Temperature: \(minimumTemperature) \(unit.displayTitle)"
    }

    var maximumTemperatureDisplayValue: String {
        return "Maximum Temperature: \(maximumTemperature) \(unit.displayTitle)"
    }

    var averageTemperatureDisplayValue: String {
        return "Average Temperature: \(averageTemperature) \(unit.displayTitle)"
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

