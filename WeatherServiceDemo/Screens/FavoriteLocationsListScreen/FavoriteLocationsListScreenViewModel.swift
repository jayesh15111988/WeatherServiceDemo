//
//  FavoriteLocationsListScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

final class FavoriteLocationsListScreenViewModel {

    weak var view: FavoriteLocationsListViewable?
    var favoriteLocationModels: [Location]
    let title: String

    var router: FavoriteLocationsListScreenRouter?

    init(favoriteLocationModels: [Location]) {
        self.favoriteLocationModels = favoriteLocationModels
        self.title = "Favorites"
    }

    func removeLocationFromFavorites(at index: Int) {
        let favoriteLocationToRemove = favoriteLocationModels[index]
        favoriteLocationToRemove.toggleFavoriteStatus()
        favoriteLocationModels.remove(at: index)

        if favoriteLocationModels.isEmpty {
            view?.showAlert(with: "No Favorites", message: "You don't have any favorites. Please click on star icon to add location to favorites list", actions: [UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.router?.dismiss()
            })])
        }
    }

    func goToLocationForecastDetailsPage(with location: Location) {
        router?.navigateToLocationForecastDetailsPage(with: location)
    }

    func dismissCurrentView() {
        router?.dismiss()
    }
}
