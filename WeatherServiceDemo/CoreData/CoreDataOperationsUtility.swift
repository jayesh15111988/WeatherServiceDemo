//
//  CoreDataOperationsUtility.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import CoreData
import UIKit

import OSLog

final class CoreDataOperationsUtility {

    private let coreDataStore: CoreDataStoreable
    private let context: NSManagedObjectContext

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CoreDataOperationsUtility.self)
    )

    init(coreDataStore: CoreDataStoreable) {
        self.coreDataStore = coreDataStore
        self.context = coreDataStore.context
    }
    
    /// A method to update favorite status of selected location in the core data cache
    /// - Parameter id: The id of passed location
    func toggleFavoriteStatusForLocation(with id: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            if let cachedLocations = try self.context.fetch(fetchRequest).first {

                let isFavorite = (cachedLocations.value(forKey: "isFavorite") as? Bool) ?? false

                cachedLocations.setValue(!isFavorite, forKey: "isFavorite")

                try self.context.save()
            }
        } catch let error as NSError {
            Self.logger.error("An error occurred while trying to update favorite status of location with id \(id). Error details \(error.localizedDescription)")
        }
    }

    func getCachedLocations(completion: @escaping (([Location]) -> Void)) {
        let locationsListFromCache = self.locationsListFromCache(with: self.context)
        completion(locationsListFromCache)
    }

    func storeLocationsInCache(with locationsList: [Location]) {

        guard let entity = NSEntityDescription.entity(forEntityName: "Location", in: self.context) else {
            Self.logger.error("Unable to locate Location entity in the data model. Existing the flow")
            return
        }

        locationsList.forEach { newLocation in

            let location = NSManagedObject(entity: entity, insertInto: context)
            location.setValue(newLocation.id, forKey: "id")
            location.setValue(newLocation.name, forKey: "name")
            location.setValue(newLocation.coordinates.latitude, forKey: "latitude")
            location.setValue(newLocation.coordinates.longitude, forKey: "longitude")
            location.setValue(newLocation.isFavorite, forKey: "isFavorite")
        }

        coreDataStore.saveContext()
    }

    /// A method to get cached temperature info for passed location
    /// - Parameters:
    ///   - location: A Location object
    ///   - completion: Completion closure with current and forecast temperature details
    func getCachedTemperatureInformation(with location: Location, completion: @escaping (CurrentTemperatureViewModel?, [ForecastTemperatureViewModel]?) -> Void) {
        let cachedCurrentTemperature = self.getCachedCurrentTemperatureInfoFromDatabase(with: location)

        let cachedTemperatureForecast = self.getCachedTemperatureForecastInfoFromDatabase(with: location)

        guard let cachedCurrentTemperature, let cachedTemperatureForecast else {
            completion(nil, nil)
            return
        }
        completion(cachedCurrentTemperature, cachedTemperatureForecast)
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
        self.saveCurrentTemperatureViewModel(
            with: currentTemperatureViewModel,
            context: self.context,
            locationId: locationId
        )

        self.saveTemperatureForecastViewModel(
            with: temperatureForecastViewModels,
            context: self.context,
            locationId: locationId
        )
    }

    /// Remove the temperature data for location from cache if that's been removed from favorites
    /// - Parameter locationId: Location id of the concerned location
    func removeTemperatureData(for locationId: String) {
        self.removeCurrentTemperatureInfo(with: locationId, context: self.context)
        self.removeTemperatureForecastInfo(with: locationId, context: self.context)
    }

    //MARK: Private methods

    /// A method to load initial list of locations from local cache
    /// - Parameter managedContext: A managed context object
    /// - Returns: An array of Location objects
    private func locationsListFromCache(with managedContext: NSManagedObjectContext) -> [Location] {

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"id", ascending:true)]

        var cachedLocations: [NSManagedObject] = []

        do {
            cachedLocations = try managedContext.fetch(fetchRequest)

            let finalLocations: [Location] = cachedLocations.map { location -> Location? in
                guard let id = location.value(forKey: "id") as? String , let isFavorite = location.value(forKey: "isFavorite") as? Bool, let latitude = location.value(forKey: "latitude") as? Double, let longitude = location.value(forKey: "longitude") as? Double, let name = location.value(forKey: "name") as? String else {
                    return nil
                }
                return Location(id: id, name: name, coordinates: .init(latitude: latitude, longitude: longitude), isFavorite: isFavorite)
            }.compactMap { $0 }

            return finalLocations

        } catch let error as NSError {
            Self.logger.error("An error occurred while trying to fetch locations from local storage. Failed with error \(error.localizedDescription)")
        }
        return []
    }

    /// A method to get cached current temperature information from local cache
    /// - Parameter location: A location for which query is made
    /// - Returns: An optional CurrentTemperatureViewModel object if it exists in cache
    private func getCachedCurrentTemperatureInfoFromDatabase(with location: Location) -> CurrentTemperatureViewModel? {

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CurrentTemperature")
        fetchRequest.predicate = NSPredicate(format: "locationId == %@", location.id)

        do {
            if let cachedCurrentTemperatureInfo = try context.fetch(fetchRequest).first {

                if let lastUpdatedDateTimeString = cachedCurrentTemperatureInfo.value(forKey: "lastUpdatedDateTimeString") as? String, 
                    let temperatureCelsius = cachedCurrentTemperatureInfo.value(forKey: "temperatureCelsius") as? Double,
                    let temperatureFahrenheit = cachedCurrentTemperatureInfo.value(forKey: "temperatureFahrenheit") as? Double {

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

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ForecastTemperature")

        fetchRequest.predicate = NSPredicate(format: "locationId == %@", location.id)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"sequence", ascending:true)]
        do {
            let cachedLocations = try context.fetch(fetchRequest)

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
