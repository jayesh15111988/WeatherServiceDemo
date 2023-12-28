//
//  TemperatureUnitTests.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/28/23.
//

import XCTest
@testable import WeatherServiceDemo

final class TemperatureUnitTests: XCTestCase {
    func testThatTemperatureUnitCorrectlyReturnsDisplayTitle() {
        XCTAssertEqual(TemperatureUnit.celsius.displayTitle, "Celsius")
        XCTAssertEqual(TemperatureUnit.fahrenheit.displayTitle, "Fahrenheit")
    }
}
