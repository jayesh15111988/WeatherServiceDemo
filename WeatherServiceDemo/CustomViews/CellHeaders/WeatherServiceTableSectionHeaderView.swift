//
//  WeatherServiceTableSectionHeaderView.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

/// A custom header view to show different sections in table view
final public class WeatherServiceTableSectionHeaderView: UITableViewHeaderFooterView {

    /// A view model to encode parameters needed to decorate header
    public struct ViewModel {
        let title: String
    }

    private enum Constants {
        enum Padding {
            static let horizontal: CGFloat = 10.0
            static let vertical: CGFloat = 5.0
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Style.shared.defaultTextColor
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// A method to configure header with provided view model
    /// - Parameter viewModel: A instance of WeatherServiceTableSectionHeaderView.ViewModel to decorate header view with title
    func configure(with viewModel: ViewModel) {
        self.titleLabel.text = viewModel.title
    }

    //MARK: Private methods

    private func setupViews() {
        self.contentView.addSubview(titleLabel)
        self.contentView.backgroundColor = Style.shared.backgroundColor
    }

    private func layoutViews() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Padding.horizontal),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Padding.horizontal),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Padding.vertical),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Padding.vertical)
        ])
    }
}

