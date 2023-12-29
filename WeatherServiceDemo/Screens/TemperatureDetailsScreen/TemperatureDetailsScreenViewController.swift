//
//  TemperatureDetailsScreenViewController.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import Combine
import OSLog
import UIKit

final class TemperatureDetailsScreenViewController: UIViewController {

    private let activityIndicatorViewProvider = ActivityIndicatorViewProvider()
    private let favoriteButton = UIButton(frame: .zero)

    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(frame: .zero)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: TemperatureDetailsScreenViewController.self)
    )

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
        setupSubscriptions()
    }

    private let viewModel: TemperatureDetailsScreenViewModel
    private let alertDisplayUtility: AlertDisplayable
    private var cancellables: [AnyCancellable] = []

    init(viewModel: TemperatureDetailsScreenViewModel, alertDisplayUtility: AlertDisplayable) {
        self.viewModel = viewModel
        self.alertDisplayUtility = alertDisplayUtility
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Private methods
    private func setupViews() {
        self.title = viewModel.title
        self.view.backgroundColor = Style.shared.backgroundColor
        self.view.addSubview(tableView)
        self.view.addSubview(segmentedControl)

        self.activityIndicatorViewProvider.addToSuperViewAndConstrain(to: self.view)
        self.tableView.delegate = self
        self.tableView.dataSource = self

        segmentedControl.insertSegment(withTitle: TemperatureUnit.celsius.displayTitle, at: TemperatureUnit.celsius.rawValue, animated: false)

        segmentedControl.insertSegment(withTitle: TemperatureUnit.fahrenheit.displayTitle, at: TemperatureUnit.fahrenheit.rawValue, animated: false)

        segmentedControl.selectedSegmentIndex = TemperatureUnit.celsius.rawValue

        self.view.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(segmentedControlTapped), for: .valueChanged)
    }

    @objc private func segmentedControlTapped() {
        let selectedIndex = segmentedControl.selectedSegmentIndex

        guard let selectedTemperatureUnit = TemperatureUnit(rawValue: selectedIndex) else {
            Self.logger.error("App has allowed user to choose an invalid segment control index. App has entered an invalid state. Unable to proceed with state and UI update operation")
            return
        }
        self.viewModel.toggleTemperatureUnit(newTemperatureUnit: selectedTemperatureUnit)
    }

    private func layoutViews() {

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func registerCells() {

        tableView.register(WeatherServiceTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: WeatherServiceTableSectionHeaderView.reuseIdentifier)

        tableView.register(CurrentTemperatureDetailsTableViewCell.self, forCellReuseIdentifier: CurrentTemperatureDetailsTableViewCell.reuseIdentifier)
        tableView.register(ForecastTemperatureDetailsTableViewCell.self, forCellReuseIdentifier: ForecastTemperatureDetailsTableViewCell.reuseIdentifier)
    }

    private func setupNavigationBarButton() {
        favoriteButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        favoriteButton.setImage(Style.shared.favoriteImage, for: .normal)
        favoriteButton.addTarget(self, action:#selector(favoriteButtonPressed), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: favoriteButton)
        self.navigationItem.rightBarButtonItem = barButton
    }

    @objc private func favoriteButtonPressed() {
        viewModel.toggleLocationFavoriteStatus()
    }
}

extension TemperatureDetailsScreenViewController {
    
    /// A method to set up subscriptions for observables
    private func setupSubscriptions() {

        viewModel.$reloadTableView.filter { $0 }.receive(on: DispatchQueue.main).sink { [weak self] reloadTableView in

            guard let self else { return }

            self.tableView.reloadData()
        }.store(in: &cancellables)

        viewModel.$isLoading.dropFirst().receive(on: DispatchQueue.main).sink { [weak self] isLoading in

            guard let self else { return }

            if isLoading {
                self.activityIndicatorViewProvider.start()
            } else {
                self.activityIndicatorViewProvider.stop()
            }
        }.store(in: &cancellables)

        viewModel.$isMarkedFavorite.receive(on: DispatchQueue.main).sink { [weak self] isMarkedFavorite in

            guard let self else { return }

            if isMarkedFavorite {
                favoriteButton.setImage(Style.shared.favoriteImage, for: .normal)
            } else {
                favoriteButton.setImage(Style.shared.nonFavoriteImage, for: .normal)
            }
        }.store(in: &cancellables)
    }
}

extension TemperatureDetailsScreenViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let currentSection = viewModel.sections[indexPath.section]

        switch currentSection {
        case .currentTemperature(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CurrentTemperatureDetailsTableViewCell.reuseIdentifier, for: indexPath) as? CurrentTemperatureDetailsTableViewCell else {
                fatalError("Unable to get cell of type CurrentTemperatureDetailsTableViewCell from the table view")
            }
            cell.configure(with: viewModel)
            return cell
        case .forecastTemperatures(let viewModels):

            guard let cell = tableView.dequeueReusableCell(withIdentifier: ForecastTemperatureDetailsTableViewCell.reuseIdentifier, for: indexPath) as? ForecastTemperatureDetailsTableViewCell else {
                fatalError("Unable to get cell of type ForecastTemperatureDetailsTableViewCell from the table view")
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: WeatherServiceTableSectionHeaderView.reuseIdentifier) as? WeatherServiceTableSectionHeaderView else {
            fatalError("Could not find expected custom header view class WeatherServiceTableSectionHeaderView. Expected to find the reusable header view WeatherServiceTableSectionHeaderView for sections header")
        }

        let currentSection = viewModel.sections[section]

        headerView.configure(with: WeatherServiceTableSectionHeaderView.ViewModel(title: currentSection.title))

        return headerView
    }
}
