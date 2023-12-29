//
//  ReuseableView.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

/// A protocol to which reusable views conform to generate reuse identifier from their name
protocol ReusableView {
    static var reuseIdentifier: String { get }
}

//MARK: ReusableView protocol conformance to table view cell
extension UITableViewCell: ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

//MARK: ReusableView protocol conformance to table view header and footer view
extension UITableViewHeaderFooterView: ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
