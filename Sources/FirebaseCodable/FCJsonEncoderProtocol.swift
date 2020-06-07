//
//  FCJsonEncoderProtocol.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation

public protocol FCJsonEncoderProtocol: AnyObject {
    func encodeIntoJson<T>(_ value: T) throws -> [String: Any] where T: Codable
    func encodeToJson<T>(_ value: T) throws -> [String: Any] where T: FirebaseCodable
    func encodeToJsonArray<T>(_ value: T) throws -> [[String: Any]] where T: Codable
}

public extension FCJsonEncoderProtocol where Self: JSONEncoder {
    
    /// Convert Codable object to JSON object
    func encodeIntoJson<T>(_ value: T) throws -> [String: Any] where T: Codable {
        let data = try self.encode(value)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        //Log.verbose(json)
        return json as? [String: Any] ?? [:]
    }
    
    /// Convert FirebaseCodable object to JSON object
    /// "id" key is removed
    func encodeToJson<T>(_ value: T) throws -> [String: Any] where T: FirebaseCodable {
        let data = try self.encode(value)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        if var result = json as? [String: Any] {
            result["id"] = nil
            return result
        } else {
            return [:]
        }
    }
    
    /// Convert Codable objects to JSON objects
    func encodeToJsonArray<T>(_ value: T) throws -> [[String: Any]] where T: Codable {
        let data = try self.encode(value)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return json as? [[String: Any]] ?? [[:]]
    }
    
}
