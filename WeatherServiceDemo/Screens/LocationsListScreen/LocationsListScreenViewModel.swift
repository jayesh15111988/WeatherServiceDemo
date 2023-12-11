//
//  LocationsListScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import CoreLocation
import CoreData
import OSLog
import UIKit

final class LocationsListScreenViewModel {

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: LocationsListScreenViewModel.self)
    )

    weak var view: LocationsListScreenViewable?
    var router: LocationsListScreenRouter?

    private var locationsListScreenLocationModels: [Location] = []
    let jsonFileReader: JSONFileReadable
    let temperatureInfoUtility: TemperatureInfoUtility
    private let coreDataActionsUtility: CoreDataActionsUtility

    let title: String

    init(
        jsonFileReader: JSONFileReadable,
        temperatureInfoUtility: TemperatureInfoUtility,
        coreDataActionsUtility: CoreDataActionsUtility = CoreDataActionsUtility()
    ) {
        self.jsonFileReader = jsonFileReader
        self.temperatureInfoUtility = temperatureInfoUtility
        self.coreDataActionsUtility = coreDataActionsUtility
        self.title = "Locations List"
    }
    
    /// A method to load the initial list of locations
    func loadLocations() {

        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        DispatchQueue.global(qos: .userInitiated).async {

            guard let managedContext = appDelegate?.persistentContainer.newBackgroundContext() else {
                Self.logger.error("An error occurred while trying to load locations from local storage. The managed context associated with core data is nil")
                return
            }

            let locationsListFromCache = self.locationsListFromCache(with: managedContext)

            // If the cache is not empty, then use the data from ache
            if !locationsListFromCache.isEmpty {
                self.locationsListScreenLocationModels = locationsListFromCache
            } else {
                //If the cache is empty, load data from local JSON file. Alternatively, you can also replace local file read operation with fetching data from the network

                guard let locationsParentNode: DecodableModel.LocationsParentNode = self.jsonFileReader.getModelFromJSONFile(with: "locations") else {
                    self.view?.reloadView(with: [])
                    return
                }

                //Convert codable locations into Location object which are recognized by the view controller
                self.locationsListScreenLocationModels = locationsParentNode.locations.map { codableLocation -> Location in

                    let coordinates = codableLocation.coordinates

                    return Location(
                        id: codableLocation.id,
                        name: codableLocation.name,
                        coordinates: Location.Coordinates(
                            latitude: coordinates.latitude,
                            longitude: coordinates.longitude
                        )
                    )
                }

                self.storeLocationsInCache(with: self.locationsListScreenLocationModels, managedContext: managedContext)
            }

            DispatchQueue.main.async {
                self.view?.reloadView(with: self.locationsListScreenLocationModels)
            }
        }
    }

    /// A method to navigate to favorites page
    func goToFavoritesPage() {

        let favoriteLocations = self.locationsListScreenLocationModels.filter({ $0.isFavorite })

        if favoriteLocations.isEmpty {
            self.view?.showAlert(with: "No Favorites", message: "You have not favorited any locations yet.")
        } else {

            let favoriteStatusChangedClosure: (String) -> Void = { locationId in

                if let updatedLocationIndex = self.locationsListScreenLocationModels.firstIndex(where: { $0.id == locationId }) {
                    self.view?.reloadCell(at: updatedLocationIndex)
                }
            }

            router?.navigateToFavoritesPage(with: favoriteLocations, favoriteStatusChangedClosure: favoriteStatusChangedClosure)
        }
    }

    /// A method to toggle favorite status for the selected location
    /// - Parameter location: A location for which we need to toggle favorite status
    func toggleFavoriteStatus(for location: Location) {
        location.toggleFavoriteStatus()
        self.coreDataActionsUtility.toggleFavoriteStatusForLocation(with: location.id)
        self.loadAndCacheFavoritedLocation(location: location)
    }

    /// A method to navigate to temperature forecast details page
    /// - Parameter location: A location for which the temperature details are queried
    func goToLocationForecastDetailsPage(with location: Location) {
        self.view?.showLoadingIndicator(true)

        self.temperatureInfoUtility.loadWeatherInformation(with: location) { result in

            DispatchQueue.main.async {
                switch result {
                case .success(let temperatureInfo):

                    self.router?.navigateToLocationForecastDetailsPage(with: location, temperatureInfo: .init(currentTemperatureViewModel: temperatureInfo.0, temperatureForecastViewModels: temperatureInfo.1))

                case .failure(let failure):

                    self.view?.showAlert(with: "Error", message: failure.errorMessageString())

                }
                self.view?.showLoadingIndicator(false)
            }
        }
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

    private func storeLocationsInCache(with locationsList: [Location], managedContext: NSManagedObjectContext) {

        let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!

        locationsList.forEach { newLocation in

            let location = NSManagedObject(entity: entity, insertInto: managedContext)

            location.setValue(newLocation.id, forKey: "id")
            location.setValue(newLocation.name, forKey: "name")
            location.setValue(newLocation.coordinates.latitude, forKey: "latitude")
            location.setValue(newLocation.coordinates.longitude, forKey: "longitude")
            location.setValue(newLocation.isFavorite, forKey: "isFavorite")
        }

        do {
            try managedContext.save()
        } catch let error as NSError {
            Self.logger.error("An error occurred while trying to create new Location record in the Core data. Failed with error \(error.localizedDescription)")
        }
    }

    private func loadAndCacheFavoritedLocation(location: Location) {

        self.view?.showLoadingIndicator(true)

        guard location.isFavorite else {
            //Remove saved location info from cache
            self.temperatureInfoUtility.removeTemperatureData(for: location.id)
            self.view?.showLoadingIndicator(false)
            return
        }

        self.temperatureInfoUtility.loadWeatherInformation(with: location) { result in

            switch result {
            case .success(let cachedLocationInfoData):
                self.temperatureInfoUtility.saveTemperatureData(
                    with: location.id,
                    currentTemperatureViewModel: cachedLocationInfoData.0,
                    temperatureForecastViewModels: cachedLocationInfoData.1
                )
            case .failure(let failure):
                DispatchQueue.main.async {
                    self.view?.showAlert(with: "Error", message: "Failed to save favorited location temperature information in the cache. Failed with error \(failure.errorMessageString())")
                }
            }
            DispatchQueue.main.async {
                self.view?.showLoadingIndicator(false)
            }
        }
    }
}

final class Location {
    let id: String
    let name: String
    let coordinates: Coordinates
    private(set)var isFavorite: Bool

    init(id: String, name: String, coordinates: Coordinates, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.coordinates = coordinates
        self.isFavorite = isFavorite
    }

    var favoritesImage: UIImage? {
        return self.isFavorite ? Style.shared.favoriteImage : Style.shared.nonFavoriteImage
    }

    struct Coordinates {
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
    }

    func toggleFavoriteStatus() {
        isFavorite = !isFavorite
    }
}
