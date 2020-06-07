//
//  File.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation

public protocol FCListenerRegistration: AnyObject {
    func remove()
}

public protocol FCTimestamp: Codable {
    init(date: Date)
    func dateValue() -> Date
}

public extension FCTimestamp {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(date: try container.decode(Date.self))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.dateValue())
    }
}

public enum FCDocumentChangeType: Int {
    case added
    case modified
    case removed
}
