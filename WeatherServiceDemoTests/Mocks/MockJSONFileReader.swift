//
//  MockJSONFileReader.swift
//  WeatherServiceDemoTests
//
//  Created by Jayesh Kawli on 12/27/23.
//

import Foundation
import XCTest
@testable import WeatherServiceDemo

final class MockJSONFileReader: JSONFileReadable {

    func getModelFromJSONFile<T>(with name: String, completion: @escaping (T?) -> Void) where T : Decodable {
        guard let pathString = Bundle(for: MockJSONFileReader.self).path(forResource: name, ofType: "json") else {
            XCTFail("Mock JSON file \(name).json not found")
            completion(nil)
            return
        }

        guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
            completion(nil)
            return
        }

        guard let jsonData = jsonString.data(using: .utf8) else {
            completion(nil)
            return
        }

        let model = try? JSONDecoder().decode(T.self, from: jsonData)
        completion(model)
    }
}
