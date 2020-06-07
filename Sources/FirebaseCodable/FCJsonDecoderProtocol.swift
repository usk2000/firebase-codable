//
//  FCJsonDecoderProtocol.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation

public protocol FCJsonDecoderProtocol: AnyObject {
    func decode<T>(_ type: T.Type, json: Any) throws -> T where T: Decodable
    func decode<T>(_ type: T.Type, json: [String: Any], id: String) throws -> T where T: FirebaseCodable    
}

public extension FCJsonDecoderProtocol where Self: JSONDecoder {
    
    /// convert JSON object to Codable object
    func decode<T>(_ type: T.Type, json: Any) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try self.decode(T.self, from: data)
    }
    
    /// convert JSON object to FirebaseCodable object
    func decode<T>(_ type: T.Type, json: [String: Any], id: String) throws -> T where T: FirebaseCodable {
        var input = json
        input["id"] = id
        let data = try JSONSerialization.data(withJSONObject: input, options: [])
        return try self.decode(T.self, from: data)
    }
    
}
