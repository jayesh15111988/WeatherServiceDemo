//
//  TestCoreDataStack.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/27/23.
//

import CoreData
import Foundation

@testable import WeatherServiceDemo

final class TestCoreDataStack: NSObject, CoreDataStoreable {

    override init() {
        super.init()
        deleteAllEntities()
    }

    func deleteAllEntities() {
        deleteEntity(with: "Location")
        deleteEntity(with: "ForecastTemperature")
        deleteEntity(with: "CurrentTemperature")
    }

    func deleteEntity(with name: String) {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: name)
        
        do {
            let cachedCurrentTemperatureViewModels = try context.fetch(fetchRequest)

            cachedCurrentTemperatureViewModels.forEach { context.delete($0) }

            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        try! context.save()
    }

    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return persistentContainer.persistentStoreCoordinator
    }


    lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType

        let container = NSPersistentContainer(name: "WeatherData")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
