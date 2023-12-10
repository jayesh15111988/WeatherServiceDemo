//
//  TemperatureDetailsScreenViewController.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

protocol TemperatureDetailsScreenViewable: AnyObject {
    func showAlert(with title: String, message: String)
    func refreshView(with sections: [Section])
}

final class TemperatureDetailsScreenViewController: UIViewController {

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
        loadForecastDetails()
    }

    private let viewModel: TemperatureDetailsScreenViewModel
    private let alertDisplayUtility: AlertDisplayable
    var sections: [Section] = []

    init(viewModel: TemperatureDetailsScreenViewModel, alertDisplayUtility: AlertDisplayable) {
        self.viewModel = viewModel
        self.alertDisplayUtility = alertDisplayUtility
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.title = viewModel.title
        self.view.backgroundColor = Style.shared.backgroundColor
        self.view.addSubview(tableView)

        self.activityIndicatorViewProvider.addToSuperViewAndConstrain(to: self.view)
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

        tableView.register(WeatherServiceTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: WeatherServiceTableSectionHeaderView.reuseIdentifier)

        tableView.register(CurrentTemperatureDetailsTableViewCell.self, forCellReuseIdentifier: CurrentTemperatureDetailsTableViewCell.reuseIdentifier)
        tableView.register(ForecastTemperatureDetailsTableViewCell.self, forCellReuseIdentifier: ForecastTemperatureDetailsTableViewCell.reuseIdentifier)
    }

    private func loadForecastDetails() {
        self.activityIndicatorViewProvider.start()
        viewModel.loadAndStoreForecastDetailsForCurrentLocation()
    }
}

extension TemperatureDetailsScreenViewController: TemperatureDetailsScreenViewable {
    func showAlert(with title: String, message: String) {
        self.activityIndicatorViewProvider.stop()
        alertDisplayUtility.showAlert(with: AlertInfo(title: title, message: message), parentViewController: self)
    }

    func refreshView(with sections: [Section]) {
        self.activityIndicatorViewProvider.stop()
        self.sections = sections
        self.tableView.reloadData()
    }
}

extension TemperatureDetailsScreenViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let currentSection = sections[indexPath.section]

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

        let currentSection = sections[section]

        headerView.configure(with: WeatherServiceTableSectionHeaderView.ViewModel(title: currentSection.title))

        return headerView
    }
}
