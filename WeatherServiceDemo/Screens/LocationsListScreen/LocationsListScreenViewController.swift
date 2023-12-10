//
//  LocationsListScreenViewController.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

protocol LocationsListScreenViewable: AnyObject {
    func reloadView(with locationsList: [LocationsListScreenViewModel.Location])
}

final class LocationsListScreenViewController: UIViewController {

    private var locations: [LocationsListScreenViewModel.Location] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadLocations()
    }

    private let viewModel: LocationsListScreenViewModel

    init(viewModel: LocationsListScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LocationsListScreenViewController: LocationsListScreenViewable {
    func reloadView(with locationsList: [LocationsListScreenViewModel.Location]) {
        self.locations = locationsList
    }
}
