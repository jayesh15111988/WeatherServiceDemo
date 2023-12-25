//
//  TemperatureInfoUtility.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/11/23.
//

import OSLog

import WeatherService

final class TemperatureInfoUtility {

    private let weatherService: WeatherService
    private let coreDataActionsUtility: CoreDataOperationsUtility

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TemperatureInfoUtility.self)
    )

    init(
        weatherService: WeatherService,
        coreDataActionsUtility: CoreDataOperationsUtility) {
            self.weatherService = weatherService
            self.coreDataActionsUtility = coreDataActionsUtility
    }

    /// A method to load weather information from server based on the passed location. If the server request fails with network unavailable error, we will load data from cache if that's available
    /// - Parameters:
    ///   - location: A location for which we want to query weather information
    ///   - completion: A completion closure with current and forecast temperature information
    func loadWeatherInformation(with location: Location, completion: @escaping (Result<(CurrentTemperatureViewModel, [ForecastTemperatureViewModel]), DataLoadError>) -> Void) {

        self.weatherService.forecast(
            with: .coordinates(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude), daysInFuture: 7) { [weak self] result in

                guard let self else { return }

                switch result {

                case .success(let weatherData):
                    let (currentTemperatureViewModel, forecastTemperatureViewModels) = self.convertRemoteWeatherDataToLocalViewModels(with: weatherData, location: location)
                    completion(.success((currentTemperatureViewModel, forecastTemperatureViewModels)))
                case .failure(let failure):
                    // If the network request failed, try to load it from the local cache
                    // We do this instead of using cache by default to make sure we always get the latest forecast from official source instead of stale data
                    if case .internetUnavailable = failure {
                        self.coreDataActionsUtility.getCachedTemperatureInformation(with: location) { currentTemperatureViewModel, forecastTemperatureViewModel in

                            //Check if cache has this value
                            if let currentTemperatureViewModel, let forecastTemperatureViewModel {
                                completion(.success((currentTemperatureViewModel, forecastTemperatureViewModel)))
                            } else {
                                completion(.failure(failure))
                            }
                        }
                    } else {
                        completion(.failure(failure))
                    }
                }
            }
    }

    /// A method to convert remote weather models into local view models for later use in the view controller
    /// - Parameters:
    ///   - weatherData: A network weather data
    ///   - location: A location for which weather data was requested
    /// - Returns: A tuple containing current and forecast temperature info
    private func convertRemoteWeatherDataToLocalViewModels(with weatherData: WSWeatherData, location: Location) -> (currentTemperatureViewModel: CurrentTemperatureViewModel, forecastTemperatureViewModels: [ForecastTemperatureViewModel]) {

        let currentTemperatureViewModel = CurrentTemperatureViewModel(
            temperatureCelsius: weatherData.current.temperatureCelsius,
            temperatureFahrenheit: weatherData.current.temperatureFahrenheit,
            lastUpdateDateTimeString: "Last Updated : \(weatherData.current.lastUpdateDateTimeString)",
            unit: .celsius
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

        return (currentTemperatureViewModel: currentTemperatureViewModel, forecastTemperatureViewModels: forecastTemperatureViewModels)
    }
}
