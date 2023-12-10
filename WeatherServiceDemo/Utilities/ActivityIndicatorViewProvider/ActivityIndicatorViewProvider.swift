//
//  ActivityIndicatorViewProvider.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

class ActivityIndicatorViewProvider {

    let activityIndicatorView: UIActivityIndicatorView

    init() {
        let activityIndicatorView = UIActivityIndicatorView(frame: .zero)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView = activityIndicatorView
    }

    func addToSuperViewAndConstrain(to superView: UIView) {
        superView.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: superView.centerYAnchor)
        ])
    }

    func start() {
        activityIndicatorView.startAnimating()
    }

    func stop() {
        activityIndicatorView.stopAnimating()
    }
}
