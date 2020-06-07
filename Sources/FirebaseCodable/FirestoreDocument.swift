//
//  File.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation
import FirebaseFirestore

public typealias DocumentHandler = (Result<Void, FCError>) -> Void

public extension DocumentReference {
    
    func getDocument(_ completion: @escaping (Result<DocumentSnapshot, FCError>) -> Void) {
        
        self.getDocument { (snapshot, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.firebaseError(error)))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(snapshot!))
            }
        }
        
    }
    
    func getDocument(source: FirestoreSource, completion: @escaping (Result<DocumentSnapshot, FCError>) -> Void) {
        
        self.getDocument(source: source) { (snapshot, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.firebaseError(error)))
                    return
                }
                completion(.success(snapshot!))
            }
        }
        
    }
    
}

public extension DocumentReference {
    
    /// ドキュメントを取得し、指定したタイプに変換する
    /// - Parameters:
    ///   - type: タイプ
    ///   - source: ソース(デフォルト・キャッシュ・サーバ)
    ///   - decoder: デコーダー
    func getDocumentAs<T>(_ type: T.Type, source: FirestoreSource, decoder: FCJsonDecoderProtocol, completion: @escaping (Result<T?, FCError>) -> Void) where T: FirebaseCodable {
        
        self.getDocument(source: source) { result in
                        
            DispatchQueue.main.async {
                switch result {
                case .success(let snapshot):
                    if snapshot.exists {
                        
                        do {
                            let data = snapshot.data()!
                            let value = try decoder.decode(type, json: data, id: snapshot.documentID)
                            completion(.success(value))
                        } catch let error {
                            completion(.failure(.systemError(error)))
                        }
                        
                    } else {
                        completion(.success(nil))
                    }
                    
                case .failure(let error):
                    completion(.failure(.firebaseError(error)))
                }
            }
            
        }
    }
    
    func getDocumentSyncAs<T: FirebaseCodable>(_ type: T.Type, source: FirestoreSource, decoder: FCJsonDecoderProtocol) throws -> T? {
        
        var document: T?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        self.getDocumentAs(T.self, source: source, decoder: decoder) { result in
            defer { semaphore.signal() }
            switch result {
            case .success(let doc):
                document = doc
                
            case .failure(let err):
                error = err
            }
        }
        
        semaphore.wait()
        
        if let error = error {
            throw error
        }
        
        return document
    }
    
    @discardableResult
    func addSnapshotListenerAs<T: FirebaseCodable>(_ type: T.Type, decoder: FCJsonDecoderProtocol, completion: @escaping (Result<T?, FCError>) -> Void) -> ListenerRegistration {
        
        return self.addSnapshotListener { snapshot, error in
                        
            if let error = error {
                completion(.failure(FCError.firebaseError(error)))
            } else {
                let snapshot = snapshot!
                
                if snapshot.exists {
                    
                    do {
                        let data = snapshot.data()!
                        let value = try decoder.decode(type, json: data, id: snapshot.documentID)
                        completion(.success(value))
                    } catch let error {
                        completion(.failure(.systemError(error)))
                    }
                    
                } else {
                    completion(.success(nil))
                }
                
            }
            
        }
    }
}
 
public extension DocumentReference {
    
    func setDataAsJson<T>(_ data: T, encoder: FCJsonEncoderProtocol, completion: @escaping (Result<Void, FCError>) -> Void) where T: FirebaseCodable {
        
        do {
            let json = try encoder.encodeToJson(data)
            setData(documentData: json, completion: completion)
        } catch let error {
            completion(.failure(.systemError(error)))
        }
        
    }
    
    func setDataAsJsonSync<T: FirebaseCodable>(_ data: T, encoder: FCJsonEncoderProtocol) throws {
        
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        self.setDataAsJson(data, encoder: encoder) { result in
            defer { semaphore.signal() }
            switch result {
            case .success:
                //nothing todo
                break
                
            case .failure(let err):
                error = err
            }
        }
        
        semaphore.wait()
        
        if let error = error {
            throw error
        }
        
    }
    
    func setData(documentData: [String: Any], completion: @escaping (Result<Void, FCError>) -> Void) {
        
        self.setData(documentData) { error in
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.firebaseError(error)))
                    return
                }
                
                completion(.success(()))
            }
            
        }
        
    }
    
    //パラメータを指定してアップデート
    func updateData(fields: [String: Any], completion: @escaping (Result<Void, FCError>) -> Void) {
        
        self.updateData(fields) { (error) in
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.firebaseError(error)))
                    return
                }
                
                completion(.success(()))
            }
            
        }
        
    }
    
    func deleteDocument(completion: @escaping ((Result<Void, FCError>) -> Void)) {
        
        delete { error in
            if let error = error {
                completion(Result.failure(.firebaseError(error)))
            } else {
                completion(Result.success(()))
            }
        }
        
    }
    
}
