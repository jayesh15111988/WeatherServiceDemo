//
//  LocationsListScreenViewController.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import Combine
import UIKit

final class LocationsListScreenViewController: UIViewController {

    private var locations: [Location] = []

    private let activityIndicatorViewProvider = ActivityIndicatorViewProvider()

    private var cancellables: [AnyCancellable] = []

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
        setupSubscriptions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLocations()
    }

    private let viewModel: LocationsListScreenViewModel
    private let alertDisplayUtility: AlertDisplayable

    init(viewModel: LocationsListScreenViewModel, alertDisplayUtility: AlertDisplayable) {
        self.viewModel = viewModel
        self.alertDisplayUtility = alertDisplayUtility
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.view.backgroundColor = Style.shared.backgroundColor
        self.view.addSubview(tableView)
        self.title = viewModel.title

        self.activityIndicatorViewProvider.addToSuperViewAndConstrain(to: self.view)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        setupNavigationBarButton()
    }

    func setupNavigationBarButton() {
        let button = UIButton(frame: .zero)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(Style.shared.favoriteImage, for: .normal)
        button.addTarget(self, action:#selector(favoriteButtonPressed), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }

    @objc private func favoriteButtonPressed() {
        viewModel.goToFavoritesPage()
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

extension LocationsListScreenViewController {

    func setupSubscriptions() {
        viewModel.$locations.compactMap { $0 }.receive(on: DispatchQueue.main).sink { [weak self] locations in
            guard let self else { return }

            self.locations = locations
            self.tableView.reloadData()

        }.store(in: &cancellables)

        viewModel.$alertInfo.compactMap { $0 }.receive(on: DispatchQueue.main).sink { [weak self] alertInfo in
            guard let self else { return }

            self.alertDisplayUtility.showAlert(with: alertInfo, parentViewController: self)

        }.store(in: &cancellables)

        viewModel.$cellIndexToReload.compactMap { $0 }.receive(on: DispatchQueue.main).sink { [weak self] index in
            guard let self else { return }

            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)

        }.store(in: &cancellables)

        viewModel.$isLoading.compactMap { $0 }.receive(on: DispatchQueue.main).sink { [weak self] isLoading in
            guard let self else { return }
            
            if isLoading {
                self.activityIndicatorViewProvider.start()
            } else {
                self.activityIndicatorViewProvider.stop()
            }
        }.store(in: &cancellables)
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

            self.viewModel.toggleFavoriteStatus(for: location)
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
        viewModel.goToLocationForecastDetailsPage(with: locations[indexPath.row])
    }
}
