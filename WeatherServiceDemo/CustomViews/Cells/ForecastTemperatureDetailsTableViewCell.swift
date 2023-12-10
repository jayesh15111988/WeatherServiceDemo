//
//  ForecastTemperatureDetailsTableViewCell.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

final class ForecastTemperatureDetailsTableViewCell: UITableViewCell {

    private enum Constants {
        static let horizontalPadding: CGFloat = 8.0
        static let verticalPadding: CGFloat = 8.0
        static let verticalSpacing: CGFloat = 8.0
    }

    let lastUpdatedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let minimumTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let maximumTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let averageTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        lastUpdatedDateLabel.text = nil
        minimumTemperatureLabel.text = nil
        maximumTemperatureLabel.text = nil
        averageTemperatureLabel.text = nil
    }

    // MARK: Private methods

    private func setupViews() {
        contentView.addSubview(lastUpdatedDateLabel)
        contentView.addSubview(minimumTemperatureLabel)
        contentView.addSubview(maximumTemperatureLabel)
        contentView.addSubview(averageTemperatureLabel)
        self.selectionStyle = .none
    }

    private func layoutViews() {

        NSLayoutConstraint.activate([
            minimumTemperatureLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPadding),
            minimumTemperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            minimumTemperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding)
        ])

        NSLayoutConstraint.activate([
            maximumTemperatureLabel.topAnchor.constraint(equalTo: minimumTemperatureLabel.bottomAnchor, constant: Constants.verticalSpacing),
            maximumTemperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            maximumTemperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding)
        ])

        NSLayoutConstraint.activate([
            averageTemperatureLabel.topAnchor.constraint(equalTo: maximumTemperatureLabel.bottomAnchor, constant: Constants.verticalSpacing),
            averageTemperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            averageTemperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding)
        ])

        NSLayoutConstraint.activate([
            lastUpdatedDateLabel.topAnchor.constraint(equalTo: averageTemperatureLabel.bottomAnchor, constant: Constants.verticalSpacing),
            lastUpdatedDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            lastUpdatedDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            lastUpdatedDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalPadding),
        ])
    }

    func configure(with viewModel: ForecastTemperatureViewModel) {
        self.lastUpdatedDateLabel.text = viewModel.lastUpdatedDateString
        self.minimumTemperatureLabel.text = viewModel.minimumTemperatureDisplayValue
        self.maximumTemperatureLabel.text = viewModel.maximumTemperatureDisplayValue
        self.averageTemperatureLabel.text = viewModel.averageTemperatureDisplayValue
    }
}
