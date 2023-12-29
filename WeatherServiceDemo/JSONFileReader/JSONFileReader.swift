//
//  JSONFileReader.swift
//  WeatherServiceDemo
//
//  Created by Jayesh Kawli on 12/10/23.
//

import Foundation

protocol JSONFileReadable {
    func getModelFromJSONFile<T: Decodable>(with name: String, completion: @escaping (T?) -> Void)
}

/// <#Description#>
final class JSONFileReader: JSONFileReadable {

    /// A method to get the specified Decodable model after converting local JSON data into model object
    /// - Parameters:
    ///   - name: Name of the JSON file to read the data from
    ///   - completion: A completion closure returning generic type T conforming to Decodable protocol
    func getModelFromJSONFile<T: Decodable>(with name: String, completion: @escaping (T?) -> Void) {

        DispatchQueue.global(qos: .default).async {
            guard let jsonData = self.getDataFromJSONFile(with: name) else {
                completion(nil)
                return
            }

            completion(try? JSONDecoder().decode(T.self, from: jsonData))
        }
    }

    /// A method to get Data for JSON values read from local JSON file
    /// - Parameter name: Name of the JSON file to read the data from
    /// - Returns: A Data object if data or file exists, otherwise nil
    func getDataFromJSONFile(with name: String) -> Data? {
        guard let pathString = Bundle(for: type(of: self)).path(forResource: name, ofType: "json") else {
            return nil
        }

        guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
            return nil
        }

        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        return jsonData
    }
}
