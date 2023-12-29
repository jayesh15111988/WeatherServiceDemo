//
//  ActivityIndicatorViewProvider.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

/// A class to perform loading indicator actions while loading data
final class ActivityIndicatorViewProvider {

    private let activityIndicatorView: UIActivityIndicatorView

    init() {
        let activityIndicatorView = UIActivityIndicatorView(frame: .zero)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView = activityIndicatorView
    }
    
    /// A method to add activityIndicatorView to passed super view
    /// - Parameter superView: A superView to which we need to add activityIndicatorView
    func addToSuperViewAndConstrain(to superView: UIView) {
        superView.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: superView.centerYAnchor)
        ])
    }
    
    /// A method to start activityIndicator spinning
    func start() {
        activityIndicatorView.startAnimating()
    }

    /// A method to stop activityIndicator spinning
    func stop() {
        activityIndicatorView.stopAnimating()
    }
}
