//
//  CoreDataStore.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/25/23.
//

import CoreData
import Foundation

protocol CoreDataStoreable: AnyObject {
    var persistentContainer: NSPersistentContainer { get }
    var context: NSManagedObjectContext { get }
    func saveContext ()
}

/// A core data store to centralize core data core code
final class CoreDataStore: CoreDataStoreable {

    let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext

    /// A singleton instance for a core data store
    static let shared = CoreDataStore()

    private init() {
        self.persistentContainer = NSPersistentContainer(name: "WeatherData")
        self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.context = persistentContainer.viewContext
    }

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let saveContextError = error as NSError
                fatalError("Unresolved error while saving the data in local cache \(saveContextError), \(saveContextError.userInfo)")
            }
        }
    }
}
