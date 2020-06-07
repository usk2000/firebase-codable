//
//  File.swift
//  
//
//  Created by Yusuke Hasegawa on 2020/06/07.
//

import Foundation

public extension FCDocumentReference {
    
    func getDocument(source: FCFirestoreSource, completion: @escaping (Result<FCDocumentSnapshot, FCError>) -> Void) {
        
        self.getDocument(source: source) { snapshot, error in
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

public extension FCDocumentReference {
    
    /// ドキュメントを取得し、指定したタイプに変換する
    /// - Parameters:
    ///   - type: タイプ
    ///   - source: ソース(デフォルト・キャッシュ・サーバ)
    ///   - decoder: デコーダー
    func getDocumentAs<T>(_ type: T.Type, source: FCFirestoreSource, decoder: FCJsonDecoderProtocol, completion: @escaping (Result<T?, FCError>) -> Void) where T: FirebaseCodable {
                
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
    
    func getDocumentSyncAs<T: FirebaseCodable>(_ type: T.Type, source: FCFirestoreSource, decoder: FCJsonDecoderProtocol) throws -> T? {
        
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
    func addSnapshotListenerAs<T: FirebaseCodable>(_ type: T.Type, decoder: FCJsonDecoderProtocol, completion: @escaping (Result<T?, FCError>) -> Void) -> FCListenerRegistration {
        
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
 
public extension FCDocumentReference {
    
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
