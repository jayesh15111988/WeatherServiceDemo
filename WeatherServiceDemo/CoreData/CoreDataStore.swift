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

final class CoreDataStore: CoreDataStoreable {

    let persistentContainer: NSPersistentContainer
    let context: NSManagedObjectContext

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
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
