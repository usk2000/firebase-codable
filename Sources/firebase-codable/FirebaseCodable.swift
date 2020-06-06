//
//  FirebaseCodable.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/05.
//

import Foundation
import FirebaseFirestore

protocol FirebaseCodable: Codable {
    var id: String { get }
}

public protocol TimestampType: Codable {
    init(date: Date)
    func dateValue() -> Date
}

extension TimestampType {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(date: try container.decode(Date.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.dateValue())
    }
}

extension Timestamp: TimestampType {
    
}


