//
//  main.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/27/23.
//

import UIKit

private func delegateClassName() -> String? {
    if NSClassFromString("WeatherServiceDemoUITests") != nil { // UI Testing
        return NSStringFromClass(AppDelegate.self)
    } else if NSClassFromString("XCTestCase") != nil { // Unit Testing
        return nil
    } else { // App
        return NSStringFromClass(AppDelegate.self)
    }
}

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, delegateClassName())
