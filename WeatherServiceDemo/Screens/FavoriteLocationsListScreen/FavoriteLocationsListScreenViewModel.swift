//
//  FavoriteLocationsListScreenViewModel.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import Foundation

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
    }
}
