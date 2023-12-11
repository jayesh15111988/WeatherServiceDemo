//
//  LocationTableViewCell.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

final class LocationTableViewCell: UITableViewCell {
    
    /// Style Constants
    private enum Constants {
        static let horizontalPadding: CGFloat = 8.0
        static let verticalPadding: CGFloat = 8.0
        static let horizontalSpacing: CGFloat = 8.0
        static let favoriteViewWidth: CGFloat = 20.0
        static let favoriteViewHeight: CGFloat = 20.0
    }

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    private let favoriteButtonView: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var favoriteButtonActionClosure: (() -> Void)?

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
        nameLabel.text = nil
        favoriteButtonView.setImage(nil, for: .normal)
    }

    func configure(with locationsModel: Location) {
        self.nameLabel.text = locationsModel.name
        self.favoriteButtonView.setImage(locationsModel.favoritesImage, for: .normal)
    }

    // MARK: Private methods

    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(favoriteButtonView)

        favoriteButtonView.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }

    private func layoutViews() {

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPadding),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalSpacing),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.verticalPadding)
        ])

        NSLayoutConstraint.activate([
            favoriteButtonView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButtonView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            favoriteButtonView.heightAnchor.constraint(equalToConstant: Constants.favoriteViewHeight),
            favoriteButtonView.widthAnchor.constraint(equalToConstant: Constants.favoriteViewWidth)
        ])
    }

    @objc private func favoriteButtonTapped() {
        favoriteButtonActionClosure?()
    }
}
