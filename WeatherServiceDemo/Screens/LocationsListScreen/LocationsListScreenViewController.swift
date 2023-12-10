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

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderTopPadding = 0
        tableView.tableFooterView = nil
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()
        registerCells()
        loadLocations()
    }

    private let viewModel: LocationsListScreenViewModel

    init(viewModel: LocationsListScreenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.view.backgroundColor = Style.shared.backgroundColor
        self.view.addSubview(tableView)
        self.title = viewModel.title

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    func layoutViews() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func registerCells() {
        tableView.register(WeatherServiceTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: WeatherServiceTableSectionHeaderView.reuseIdentifier)

        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.reuseIdentifier)
    }

    func loadLocations() {
        viewModel.loadLocations()
    }
}

extension LocationsListScreenViewController: LocationsListScreenViewable {
    func reloadView(with locationsList: [LocationsListScreenViewModel.Location]) {
        self.locations = locationsList
        self.tableView.reloadData()
    }
}

extension LocationsListScreenViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseIdentifier, for: indexPath) as? LocationTableViewCell else {
            fatalError("Unable to get cell of type LocationTableViewCell from the table view")
        }

        let location = locations[indexPath.row]
        cell.configure(with: location)
        cell.favoriteButtonActionClosure = { [weak self] in
            guard let self else { return }

            location.toggleFavoriteStatus()
            self.tableView.reloadRows(at: [IndexPath(item: indexPath.row, section: 0)], with: .automatic)
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: WeatherServiceTableSectionHeaderView.reuseIdentifier) as? WeatherServiceTableSectionHeaderView else {
            fatalError("Could not find expected custom header view class WeatherServiceTableSectionHeaderView. Expected to find the reusable header view WeatherServiceTableSectionHeaderView for sections header")
        }
        headerView.configure(with: WeatherServiceTableSectionHeaderView.ViewModel(title: "Locations"))

        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
