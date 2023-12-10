//
//  CoreDataActionsUtility.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import CoreData
import UIKit

final class CoreDataActionsUtility {

    let appDelegate: AppDelegate

    init() {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
    }

    func toggleFavoriteStatusForLocation(with id: String) {

        DispatchQueue.global().async {
            let managedContext = self.appDelegate.persistentContainer.viewContext

            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)

            do {
                if let cachedLocations = try managedContext.fetch(fetchRequest).first {
                    let isFavorite = (cachedLocations.value(forKey: "isFavorite") as? Bool) ?? false

                    cachedLocations.setValue(!isFavorite, forKey: "isFavorite")

                    try managedContext.save()
                }
            } catch let error as NSError {
                //TODO: Add logging
                print(error.localizedDescription)
            }
        }
    }

    func saveTemperatureData(
        with locationId: String,
        currentTemperatureViewModel: CurrentTemperatureViewModel,
        temperatureForecastViewModels: [ForecastTemperatureViewModel]
    ) {
        DispatchQueue.global().async {
            let managedContext = self.appDelegate.persistentContainer.viewContext

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
            //TODO: Add logging
            print(error.localizedDescription)
        }
    }

    private func saveTemperatureForecastViewModel(with viewModels: [ForecastTemperatureViewModel], context: NSManagedObjectContext, locationId: String) {

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
            //TODO: Add logging
            print(error.localizedDescription)
        }
    }
}
