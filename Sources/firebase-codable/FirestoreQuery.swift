//
//  File.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation
import FirebaseFirestore

extension Query {
    
    func fetchDocuments(source: FirestoreSource, completion: @escaping (Result<QuerySnapshot, FCError>) -> Void) {
        
        self.getDocuments(source: source) { snapshot, error in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    completion(.failure(.firebaseError(error)))
                    return
                }
                
                completion(.success(snapshot!))
            }
            
        }
        
    }
    
    func getDocuments(source: FirestoreSource, completion: @escaping (Result<QuerySnapshot, FCError>) -> Void) {
        
        self.getDocuments(source: source) { (snapshot, error) in
            
            if let error = error as NSError? {
                completion(.failure(.firebaseError(error)))
                return
            }
            
            completion(.success(snapshot!))
            
        }
        
    }
        
    func getDocumentsAs<T>(_ type: T.Type, source: FirestoreSource, decoder: FCJsonDecoderProtocol, completion: @escaping (Result<[T], FCError>) -> Void) where T: FirebaseCodable {
        
        self.getDocuments(source: source) { (snapshot, error) in
            
            if let error = error as NSError? {
                DispatchQueue.main.async {
                    completion(.failure(.firebaseError(error)))
                }
                return
            }
            
            let result = snapshot!.documents.compactMap({ child -> T? in
                do {
                    return try decoder.decode(type, json: child.data(), id: child.documentID)
                } catch let error {
                    Log.verbose(error)
                    return nil
                }
            })
            
            DispatchQueue.main.async {
                completion(.success(result))
            }
            
        }
        
    }
    
    func getDocumentResponseAs<T>(_ type: T.Type, source: FirestoreSource, decoder: FCJsonDecoderProtocol, completion: @escaping (Result<DocumentResponse<T>, FCError>) -> Void) where T: FirebaseCodable {
        
        self.getDocuments(source: source) { snapshot, error in
            
            if let error = error as NSError? {
                DispatchQueue.main.async {
                    completion(.failure(.firebaseError(error)))
                }
                return
            }
            
            let result = snapshot!.documents.compactMap({ child -> T? in
                do {
                    return try decoder.decode(type, json: child.data(), id: child.documentID)
                } catch let error {
                    Log.verbose(child.reference.path)
                    Log.verbose(error)
                    return nil
                }
            })
            
            let response = DocumentResponse<T>.init(items: result, lastSnapshot: snapshot!.documents.last)
            DispatchQueue.main.async {
                completion(.success(response))
            }
            
        }
        
    }
    
    func getDocumentsSync<T: FirebaseCodable>(_ type: T.Type, source: FirestoreSource, decoder: FCJsonDecoderProtocol) throws -> [T] {
        
        var documents: [T] = []
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        fetchDocuments(source: source) { result in
            defer { semaphore.signal() }
            switch result {
            case .success(let snapshot):
                documents = snapshot.documents.compactMap({ child -> T? in
                    do {
                        return try decoder.decode(type, json: child.data(), id: child.documentID)
                    } catch let error {
                        Log.debug(error)
                        return nil
                    }
                })
                
            case .failure(let err):
                error = err
            }
        }
        
        semaphore.wait()
        
        if let error = error {
            throw error
        }
        
        return documents
    }
    
    func getDocumentsSync(source: FirestoreSource) throws -> QuerySnapshot {
        var snapshot: QuerySnapshot?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)

        fetchDocuments(source: source) { result in
            defer { semaphore.signal() }
            switch result {
            case .success(let snap):
                snapshot = snap
            case .failure(let err):
                error = err
            }
        }
        
        semaphore.wait()
        
        if let error = error {
            throw error
        }
        
        return snapshot!
    }
    
    @discardableResult
    func addSnapshotListenerAs<T: FirebaseCodable>(_ type: T.Type, decoder: FCJsonDecoderProtocol, completion: @escaping (Result<FCSnapshotDiff<T>, FCError>) -> Void) -> ListenerRegistration {
        
        return addSnapshotListener({ snapshot, error in
            if let error = error {
                completion(.failure(FCError.firebaseError(error)))
            } else {
                
                guard let snapshot = snapshot else { return }
                
                let added = snapshot.documentChanges.filter({ $0.type == .added }).compactMap({ change -> T? in
                    do {
                        return try decoder.decode(type, json: change.document.data(), id: change.document.documentID)
                    } catch let error {
                        Log.debug(error)
                        return nil
                    }
                })
                let modified = snapshot.documentChanges.filter({ $0.type == .modified }).compactMap({ change -> T? in
                    do {
                        return try decoder.decode(type, json: change.document.data(), id: change.document.documentID)
                    } catch let error {
                        Log.debug(error)
                        return nil
                    }
                })
                let removed = snapshot.documentChanges.filter({ $0.type == .removed }).compactMap({ change -> T? in
                    do {
                        return try decoder.decode(type, json: change.document.data(), id: change.document.documentID)
                    } catch let error {
                        Log.debug(error)
                        return nil
                    }
                })
                
                var diffs: [SnapshotDiff<T>] = []
                if !removed.isEmpty { diffs.append(.removed(removed))}
                if !modified.isEmpty { diffs.append(.modified(modified))}
                if !added.isEmpty { diffs.append(.added(added)) }

                completion(.success(FCSnapshotDiff<T>(diffs: diffs)))
            }
        })
        
    }

}