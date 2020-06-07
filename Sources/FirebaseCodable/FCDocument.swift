//
//  File.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation

public typealias FCDocumentHandler = (Result<Void, FCError>) -> Void

public protocol FCDocumentReference: AnyObject {
    associatedtype FCFirestoreSource
    associatedtype FCListenerRegistration
    func getDocument(source: FCFirestoreSource, completion: @escaping (FCDocumentSnapshot?, Error?) -> Void)
    func setData(_ documentData: [String: Any], completion: ((Error?) -> Void)?)
    func updateData(_ fields: [AnyHashable : Any], completion: ((Error?) -> Void)?)
    func delete(completion: ((Error?) -> Void)?)
    func addSnapshotListener(_ listener: @escaping (FCDocumentSnapshot?, Error?) -> Void) -> FCListenerRegistration
}

public protocol FCDocumentSnapshot: AnyObject {
    var documentID: String { get }
    var exists: Bool { get }
    func data() -> [String: Any]?
}
