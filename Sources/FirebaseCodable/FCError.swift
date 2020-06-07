//
//  FCError.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation

public enum FCError: Error {
    case firebaseError(Error)
    case systemError(Error)
}
