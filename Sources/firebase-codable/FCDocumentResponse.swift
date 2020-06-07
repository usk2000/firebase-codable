//
//  FCDocumentResponse.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation

struct FCDocumentResponse<T> {
    let items: [T]
    let lastSnapshot: DocumentSnapshot?
}
