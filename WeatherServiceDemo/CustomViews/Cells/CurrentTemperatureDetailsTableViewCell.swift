//
//  CurrentTemperatureDetailsTableViewCell.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

class CurrentTemperatureDetailsTableViewCell: UITableViewCell {

    private enum Constants {
        static let horizontalPadding: CGFloat = 8.0
        static let verticalPadding: CGFloat = 8.0
        static let verticalSpacing: CGFloat = 8.0
    }

    let lastUpdatedDateTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let currentTemperatureLabel: UILabel = {
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
        lastUpdatedDateTimeLabel.text = nil
        currentTemperatureLabel.text = nil
    }

    // MARK: Private methods

    private func setupViews() {
        contentView.addSubview(lastUpdatedDateTimeLabel)
        contentView.addSubview(currentTemperatureLabel)
        self.selectionStyle = .none
    }

    private func layoutViews() {

        NSLayoutConstraint.activate([
            currentTemperatureLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPadding),
            currentTemperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            currentTemperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding)
        ])

        NSLayoutConstraint.activate([
            lastUpdatedDateTimeLabel.topAnchor.constraint(equalTo: currentTemperatureLabel.bottomAnchor, constant: Constants.verticalSpacing),
            lastUpdatedDateTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            lastUpdatedDateTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            lastUpdatedDateTimeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalPadding),
        ])
    }

    func configure(with viewModel: CurrentTemperatureViewModel) {
        self.lastUpdatedDateTimeLabel.text = viewModel.lastUpdateDateTimeString
        self.currentTemperatureLabel.text = viewModel.temperatureDisplayValue
    }
}
