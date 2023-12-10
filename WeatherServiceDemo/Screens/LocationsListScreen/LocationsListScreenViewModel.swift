//
//  LocationsListScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import CoreLocation
import CoreData
import UIKit

final class LocationsListScreenViewModel {

    weak var view: LocationsListScreenViewable?
    var router: LocationsListScreenRouter?

    private var locationsListScreenLocationModels: [Location] = []
    let jsonFileReader: JSONFileReadable
    let title: String

    init(jsonFileReader: JSONFileReadable) {
        self.jsonFileReader = jsonFileReader
        self.title = "Locations List"
    }

    func loadLocations() {

        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        DispatchQueue.global(qos: .userInitiated).async {

            let managedContext = appDelegate?.persistentContainer.viewContext

            let locationsListFromCache = self.locationsListFromCache(with: managedContext)

            if !locationsListFromCache.isEmpty {
                self.locationsListScreenLocationModels = locationsListFromCache
            } else {
                guard let locationsParentNode: DecodableModel.LocationsParentNode = self.jsonFileReader.getModelFromJSONFile(with: "locations") else {
                    self.view?.reloadView(with: [])
                    return
                }
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

    private func locationsListFromCache(with managedContext: NSManagedObjectContext?) -> [Location] {

        guard let managedContext else { return [] }

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")

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
            //TODO: Add logging
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }

    private func storeLocationsInCache(with locationsList: [Location], managedContext: NSManagedObjectContext?) {

        guard let managedContext else {
            //TODO: Add error logging
            return
        }

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
            //TODO: add error logging
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

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

    func goToLocationForecastDetailsPage(with location: Location) {
        self.router?.navigateToLocationForecastDetailsPage(with: location)
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
