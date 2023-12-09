//
//  Router.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import UIKit

protocol Router: AnyObject {
    var rootViewController: UINavigationController { get }

    func start()
}

