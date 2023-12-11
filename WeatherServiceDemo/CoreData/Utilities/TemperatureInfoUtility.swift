//
//  TemperatureInfoUtility.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/11/23.
//

import CoreData
import OSLog
import UIKit

import WeatherService

final class TemperatureInfoUtility {
    private let weatherService: WeatherService
    private let coreDataActionsUtility: CoreDataActionsUtility
    private let appDelegate: AppDelegate

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TemperatureInfoUtility.self)
    )

    init(
        weatherService: WeatherService,
        coreDataActionsUtility: CoreDataActionsUtility = CoreDataActionsUtility(),
        appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate) {
        self.weatherService = weatherService
        self.coreDataActionsUtility = coreDataActionsUtility
        self.appDelegate = appDelegate
    }
    
    /// A method to load weather information from server based on the passed location. If the server request fails with network unavailable error, we will load data from cache if that's available
    /// - Parameters:
    ///   - location: A location for which we want to query weather information
    ///   - completion: A completion closure with current and forecast temperature information
    func loadWeatherInformation(with location: Location, completion: @escaping (Result<(CurrentTemperatureViewModel, [ForecastTemperatureViewModel]), DataLoadError>) -> Void) {

        self.weatherService.forecastAndCurrentTemperature(
            for: .coordinates(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude)) { [weak self] result in

                guard let self else { return }

                switch result {

                case .success(let weatherData):
                    let (currentTemperatureViewModel, forecastTemperatureViewModels) = self.convertRemoteWeatherDataToLocalViewModels(with: weatherData, location: location)
                    completion(.success((currentTemperatureViewModel, forecastTemperatureViewModels)))
                case .failure(let failure):
                    // If the network request failed, try to load it from the local cache
                    if case .internetUnavailable = failure {
                        getCachedTemperatureInformation(with: location) { currentTemperatureViewModel, forecastTemperatureViewModel in

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
    
    /// A method to get cached temperature info for passed location
    /// - Parameters:
    ///   - location: A Location object
    ///   - completion: Completion closure with current and forecast temperature details
    func getCachedTemperatureInformation(with location: Location, completion: @escaping (CurrentTemperatureViewModel?, [ForecastTemperatureViewModel]?) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let cachedCurrentTemperature = self.getCachedCurrentTemperatureInfoFromDatabase(with: location)

            let cachedTemperatureForecast = self.getCachedTemperatureForecastInfoFromDatabase(with: location)

            guard let cachedCurrentTemperature, let cachedTemperatureForecast else {
                completion(nil, nil)
                return
            }
            completion(cachedCurrentTemperature, cachedTemperatureForecast)
        }
    }
    
    /// A method to get cached current temperature information from local cache
    /// - Parameter location: A location for which query is made
    /// - Returns: An optional CurrentTemperatureViewModel object if it exists in cache
    private func getCachedCurrentTemperatureInfoFromDatabase(with location: Location) -> CurrentTemperatureViewModel? {

        let managedContext = self.appDelegate.persistentContainer.newBackgroundContext()

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CurrentTemperature")
        fetchRequest.predicate = NSPredicate(format: "locationId == %@", location.id)

        do {
            if let cachedCurrentTemperatureInfo = try managedContext.fetch(fetchRequest).first {

                if let lastUpdatedDateTimeString = cachedCurrentTemperatureInfo.value(forKey: "lastUpdatedDateTimeString") as? String, let temperatureCelsius = cachedCurrentTemperatureInfo.value(forKey: "temperatureCelsius") as? Double, let temperatureFahrenheit = cachedCurrentTemperatureInfo.value(forKey: "temperatureFahrenheit") as? Double {

                    return CurrentTemperatureViewModel(temperatureCelsius: temperatureCelsius, temperatureFahrenheit: temperatureFahrenheit, lastUpdateDateTimeString: lastUpdatedDateTimeString, unit: .celsius)

                }

            }
        } catch let error as NSError {
            Self.logger.error("An error occurred while getting cached current temperature info from local storage. Failed with error \(error.localizedDescription)")
        }
        return nil
    }

    /// A method to get cached temperature forecast details information from local cache
    /// - Parameter location: A location for which query is made
    /// - Returns: An optional array of ForecastTemperatureViewModel if it exists in cache
    private func getCachedTemperatureForecastInfoFromDatabase(with location: Location) -> [ForecastTemperatureViewModel]? {

        let managedContext = self.appDelegate.persistentContainer.newBackgroundContext()

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ForecastTemperature")

        fetchRequest.predicate = NSPredicate(format: "locationId == %@", location.id)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"sequence", ascending:true)]
        do {
            let cachedLocations = try managedContext.fetch(fetchRequest)

            let forecastViewModels: [ForecastTemperatureViewModel] = cachedLocations.map { cachedLocation -> ForecastTemperatureViewModel? in
                if let lastUpdatedDateString = cachedLocation.value(forKey: "lastUpdatedDateString") as? String, let averageTemperatureCelsius = cachedLocation.value(forKey: "averageTemperatureCelsius") as? Double, let averageTemperatureFahrenheit = cachedLocation.value(forKey: "averageTemperatureFahrenheit") as? Double, let maximumTemperatureCelsius = cachedLocation.value(forKey: "maximumTemperatureCelsius") as? Double, let maximumTemperatureFahrenheit = cachedLocation.value(forKey: "maximumTemperatureFahrenheit") as? Double, let minimumTemperatureCelsius = cachedLocation.value(forKey: "minimumTemperatureCelsius") as? Double, let minimumTemperatureFahrenheit = cachedLocation.value(forKey: "minimumTemperatureFahrenheit") as? Double {
                    return ForecastTemperatureViewModel(minimumTemperatureCelsius: minimumTemperatureCelsius, maximumTemperatureCelsius: maximumTemperatureCelsius, averageTemperatureCelsius: averageTemperatureCelsius, minimumTemperatureFahrenheit: minimumTemperatureFahrenheit, maximumTemperatureFahrenheit: maximumTemperatureFahrenheit, averageTemperatureFahrenheit: averageTemperatureFahrenheit, lastUpdatedDateString: lastUpdatedDateString, unit: .celsius)
                }
                return nil
            }.compactMap { $0 }

            return forecastViewModels

        } catch let error as NSError {
            Self.logger.error("An error occurred while getting cached temperature forecast info from local storage. Failed with error \(error.localizedDescription)")
        }
        return nil
    }
    
    /// A method to convert remote weather models into local view models for later use in the view controller
    /// - Parameters:
    ///   - weatherData: A network weather data
    ///   - location: A location for which weather data was requested
    /// - Returns: A tuple containing current and forecast temperature info
    private func convertRemoteWeatherDataToLocalViewModels(with weatherData: WSWeatherData, location: Location) -> (currentTemperatureViewModel: CurrentTemperatureViewModel, forecastTemperatureViewModels: [ForecastTemperatureViewModel]) {

        let currentTemperatureViewModel = CurrentTemperatureViewModel(
            temperatureCelsius: weatherData.currentTemperature.temperatureCelsius,
            temperatureFahrenheit: weatherData.currentTemperature.temperatureFahrenheit,
            lastUpdateDateTimeString: "Last Updated : \(weatherData.currentTemperature.lastUpdateDateTimeString)",
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
    
    /// A method to save current and forecast temperature details into core data cache
    /// - Parameters:
    ///   - locationId: Location associated with weather information
    ///   - currentTemperatureViewModel: An instance of CurrentTemperatureViewModel object
    ///   - temperatureForecastViewModels: An array of ForecastTemperatureViewModel objects
    func saveTemperatureData(
        with locationId: String,
        currentTemperatureViewModel: CurrentTemperatureViewModel,
        temperatureForecastViewModels: [ForecastTemperatureViewModel]
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let managedContext = self.appDelegate.persistentContainer.newBackgroundContext()

            self.saveCurrentTemperatureViewModel(
                with: currentTemperatureViewModel,
                context: managedContext,
                locationId: locationId
            )

            self.saveTemperatureForecastViewModel(
                with: temperatureForecastViewModels,
                context: managedContext,
                locationId: locationId
            )
        }
    }
    
    /// Remove the temperature data for location from cache if that's been removed from favorites
    /// - Parameter locationId: Location id of the concerned location
    func removeTemperatureData(for locationId: String) {
        DispatchQueue.global(qos: .userInitiated).async {

            let managedContext = self.appDelegate.persistentContainer.newBackgroundContext()

            self.removeCurrentTemperatureInfo(with: locationId, context: managedContext)
            self.removeTemperatureForecastInfo(with: locationId, context: managedContext)
        }
    }
    
    /// A method to remove current temperature information from cache
    /// - Parameters:
    ///   - locationId: id of the location
    ///   - context: Core data managed object context
    private func removeCurrentTemperatureInfo(with locationId: String, context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CurrentTemperature")
        fetchRequest.predicate = NSPredicate(format: "locationId == %@", locationId)

        do {
            let cachedCurrentTemperatureViewModels = try context.fetch(fetchRequest)

            cachedCurrentTemperatureViewModels.forEach { context.delete($0) }

            try context.save()

        } catch let error as NSError {
            Self.logger.error("An error occurred while removing current temperature info from local storage. Failed with error \(error.localizedDescription)")
        }
    }
    
    /// A method to remove temperature forecast request from core data cache
    /// - Parameters:
    ///   - locationId: Id of the concerned location
    ///   - context: Core data managed object context
    private func removeTemperatureForecastInfo(with locationId: String, context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ForecastTemperature")
        fetchRequest.predicate = NSPredicate(format: "locationId == %@", locationId)

        do {
            let cachedTemperatureForecastViewModels = try context.fetch(fetchRequest)

            cachedTemperatureForecastViewModels.forEach { context.delete($0) }

            try context.save()

        } catch let error as NSError {
            Self.logger.error("An error occurred while removing temperature forecast info from local storage. Failed with error \(error.localizedDescription)")
        }
    }
    
    /// A method to save current temperature view model into local cache
    /// - Parameters:
    ///   - viewModel: A current temperature view model instance
    ///   - context: Core data managed object context
    ///   - locationId: Id of the concerned location
    private func saveCurrentTemperatureViewModel(with viewModel: CurrentTemperatureViewModel, context: NSManagedObjectContext, locationId: String) {

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CurrentTemperature")
        fetchRequest.predicate = NSPredicate(format: "locationId == %@", locationId)

        do {
            let cachedCurrentTemperatureViewModels = try context.fetch(fetchRequest)

            guard cachedCurrentTemperatureViewModels.isEmpty else {
                return
            }

            let entity = NSEntityDescription.entity(forEntityName: "CurrentTemperature", in: context)!

            let currentTemperature = NSManagedObject(entity: entity, insertInto: context)

            currentTemperature.setValue(viewModel.lastUpdateDateTimeString, forKey: "lastUpdatedDateTimeString")
            currentTemperature.setValue(locationId, forKey: "locationId")
            currentTemperature.setValue(viewModel.temperatureCelsius, forKey: "temperatureCelsius")
            currentTemperature.setValue(viewModel.temperatureFahrenheit, forKey: "temperatureFahrenheit")

            try context.save()

        } catch let error as NSError {
            Self.logger.error("An error occurred while trying to save current temperature view model into local storage. Failed with error \(error.localizedDescription)")
        }
    }
    
    /// A method to save temperature forecast view models into local cache
    /// - Parameters:
    ///   - viewModels: An array of temperature forecast view model instances
    ///   - context: Core data managed object context
    ///   - locationId: Id of the concerned location
    private func saveTemperatureForecastViewModel(
        with viewModels: [ForecastTemperatureViewModel],
        context: NSManagedObjectContext,
        locationId: String
    ) {

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ForecastTemperature")

        fetchRequest.predicate = NSPredicate(format: "locationId == %@", locationId)

        do {
            let cachedTemperatureForecastViewModels = try context.fetch(fetchRequest)

            guard cachedTemperatureForecastViewModels.isEmpty else {
                return
            }

            for (index, viewModel) in viewModels.enumerated() {

                let entity = NSEntityDescription.entity(forEntityName: "ForecastTemperature", in: context)!

                let temperatureForecast = NSManagedObject(entity: entity, insertInto: context)

                temperatureForecast.setValue(locationId, forKey: "locationId")

                temperatureForecast.setValue(viewModel.averageTemperatureCelsius, forKey: "averageTemperatureCelsius")
                temperatureForecast.setValue(viewModel.averageTemperatureFahrenheit, forKey: "averageTemperatureFahrenheit")
                temperatureForecast.setValue(viewModel.lastUpdatedDateString, forKey: "lastUpdatedDateString")
                temperatureForecast.setValue(viewModel.maximumTemperatureCelsius, forKey: "maximumTemperatureCelsius")

                temperatureForecast.setValue(viewModel.maximumTemperatureFahrenheit, forKey: "maximumTemperatureFahrenheit")
                temperatureForecast.setValue(viewModel.minimumTemperatureCelsius, forKey: "minimumTemperatureCelsius")
                temperatureForecast.setValue(viewModel.minimumTemperatureFahrenheit, forKey: "minimumTemperatureFahrenheit")
                temperatureForecast.setValue(index, forKey: "sequence")
            }

            try context.save()

        } catch let error as NSError {
            Self.logger.error("An error occurred while trying to save temperature forecast view model into local storage. Failed with error \(error.localizedDescription)")
        }
    }
}
