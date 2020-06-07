//
//  File.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation

public protocol FCQuery: AnyObject {
    associatedtype FCFirestoreSource
    func getDocuments(source: FCFirestoreSource, completion: @escaping (FCQuerySnapshot?, Error?) -> Void)
    func addSnapshotListener(_ listener: @escaping (FCQuerySnapshot?, Error?) -> Void) -> FCListenerRegistration
}

public protocol FCQuerySnapshot: AnyObject {
    var documents: [FCQueryDocumentSnapshot] { get }
    var documentChanges: [FCDocumentChange] { get }
}

public protocol FCQueryDocumentSnapshot: AnyObject {
    var documentID: String { get }
    func data() -> [String: Any]
}

public protocol FCDocumentChange: AnyObject {
    var type: FCDocumentChangeType { get }
    var document: FCQueryDocumentSnapshot { get }
}
