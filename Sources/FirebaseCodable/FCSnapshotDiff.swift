//
//  FCSnapshotDiff.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation

open enum SnapshotDiff<T> {
    case added([T])
    case modified([T])
    case removed([T])
}

open struct FCSnapshotDiff<T> {
    let diffs: [SnapshotDiff<T>]
}

public extension FCSnapshotDiff where T: FirebaseCodable, T: Equatable {
    
    @discardableResult
    static func apply(diffs: FCSnapshotDiff<T>, value: inout [T]) -> Bool {
        var modified = false

        diffs.diffs.forEach { diff in
            modified = true
            switch diff {
            case .added(let added):
                value.insert(contentsOf: added.filter({ value.firstIndex(of: $0) == nil }), at: 0)
                
            case .modified(let modified):
                modified.forEach({ val in
                    if let index = value.firstIndex(of: val) {
                        value[index] = val
                    }
                })
                
            case .removed(let removed):
                let indexs = removed.compactMap({ value.firstIndex(of: $0) }).reversed()
                indexs.forEach({ value.remove(at: $0) })
                
            }
        }
        
        return modified
    }
    
}
