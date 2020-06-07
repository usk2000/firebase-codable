//
//  FirebaseCodable.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/05.
//

import Foundation

public protocol FirebaseCodable: Codable {
    var id: String { get }
}
