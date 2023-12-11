//
//  CoreDataActionsUtility.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import CoreData
import UIKit

import OSLog

final class CoreDataActionsUtility {

    let appDelegate: AppDelegate

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CoreDataActionsUtility.self)
    )

    init(appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    /// A method to update favorite status of selected location in the core data cache
    /// - Parameter id: The id of passed location
    func toggleFavoriteStatusForLocation(with id: String) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let managedContext = self.appDelegate.persistentContainer.newBackgroundContext()

            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)

            do {
                if let cachedLocations = try managedContext.fetch(fetchRequest).first {
                    let isFavorite = (cachedLocations.value(forKey: "isFavorite") as? Bool) ?? false

                    cachedLocations.setValue(!isFavorite, forKey: "isFavorite")

                    try managedContext.save()
                }
            } catch let error as NSError {
                Self.logger.error("An error occurred while trying to update favorite status of location with id \(id). Error details \(error.localizedDescription)")
            }

        }
    }
}
