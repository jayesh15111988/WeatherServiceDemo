//
//  FavoriteLocationsListScreenViewController.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

protocol FavoriteLocationsListViewable: AnyObject {
    func showAlert(with title: String, message: String, actions: [UIAlertAction])
    func showLoadingIndicator(_ showing: Bool)
}

final class FavoriteLocationsListScreenViewController: UIViewController {

    private let activityIndicatorViewProvider = ActivityIndicatorViewProvider()

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
        setupNavigationBarButton()
        refreshViewWithFavoriteLocations()
    }

    private let viewModel: FavoriteLocationsListScreenViewModel
    private let alertDisplayUtility: AlertDisplayable
    private let coreDataActionsUtility: CoreDataActionsUtility

    init(viewModel: FavoriteLocationsListScreenViewModel, alertDisplayUtility: AlertDisplayable, coreDataActionsUtility: CoreDataActionsUtility = CoreDataActionsUtility()) {
        self.viewModel = viewModel
        self.alertDisplayUtility = alertDisplayUtility
        self.coreDataActionsUtility = coreDataActionsUtility
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Private methods
    private func setupViews() {
        self.view.backgroundColor = Style.shared.backgroundColor
        self.view.addSubview(tableView)
        self.title = viewModel.title

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    private func layoutViews() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func registerCells() {
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.reuseIdentifier)
    }

    private func refreshViewWithFavoriteLocations() {
        self.tableView.reloadData()
    }

    private func setupNavigationBarButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissButtonPressed))
    }

    @objc private func dismissButtonPressed() {
        self.viewModel.dismissCurrentView()
    }
}

extension FavoriteLocationsListScreenViewController: FavoriteLocationsListViewable {
    func showAlert(with title: String, message: String, actions: [UIAlertAction]) {
        alertDisplayUtility.showAlert(with: AlertInfo(title: title, message: message, actions: actions), parentViewController: self)
    }

    func showLoadingIndicator(_ showing: Bool) {
        if showing {
            self.activityIndicatorViewProvider.start()
        } else {
            self.activityIndicatorViewProvider.stop()
        }
    }
}

extension FavoriteLocationsListScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoriteLocationModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseIdentifier, for: indexPath) as? LocationTableViewCell else {
            fatalError("Unable to get cell of type LocationTableViewCell from the table view")
        }

        let location = viewModel.favoriteLocationModels[indexPath.row]
        cell.configure(with: location)
        cell.favoriteButtonActionClosure = { [weak self] in
            guard let self else { return }

            guard let currentIndexPath = tableView.indexPath(for: cell) else {
                self.showAlert(with: "Invalid State", message: "Unfortunately app has reached an invalid state. Please restart the app to continue using the app", actions: [])
                return
            }
            viewModel.removeLocationFromFavorites(at: currentIndexPath.row)
            coreDataActionsUtility.toggleFavoriteStatusForLocation(with: location.id)
            self.removeFavoriteCellFromTableView(for: currentIndexPath)
        }

        return cell
    }

    func removeFavoriteCellFromTableView(for indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.goToLocationForecastDetailsPage(with: viewModel.favoriteLocationModels[indexPath.row])
    }
}
