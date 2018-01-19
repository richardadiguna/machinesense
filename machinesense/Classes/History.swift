//
//  History.swift
//  machinesense
//
//  Created by Richard Adiguna on 30/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import Foundation
import Firebase

class History {
    
    var _addedDateTime: Date?
    var _type: Int?
    var _result: String?
    
    var _savedImageURL: String?
    
    required init() {
        
    }
    
    convenience init(addedDateTime: Date, type: Int, result: String) {
        self.init()
        self._addedDateTime = addedDateTime
        self._type = type
        self._result = result
    }
    
    public var addedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        guard let _addedDateTime = _addedDateTime else { return "Added date is not defined"}
        
        let dateString = formatter.string(from: _addedDateTime)
        
        return dateString
    }
    
    public var type: Int {
        return _type ?? 4
    }
    
    public var categoryType: CategoryType {
        if let type = _type {
            return CategoryType(rawValue: type)!
        } else {
            return CategoryType.default
        }
    }
    
    public var result: String {
        return _result ?? ""
    }
    
    public var savedImageURL: String {
        get {
            return _savedImageURL ?? ""
        }
        set {
            _savedImageURL = newValue
        }
    }
    
    static func fetchAllHistoryWithSingleEvent(uid: String, completion: @escaping (DataSnapshot)->Void) {
        let databaseRef = Database.database().reference()
        let usersRef = databaseRef.child("users").child(uid)
        
        let historyRef = usersRef.child("histories")
        let historyRefHandle = historyRef.observeSingleEvent(of: .value, with: completion)
    }
    
    static func saveHistoryWithImage(_ history: History, image: UIImage, uid: String, completionHandler: @escaping ()->Void) {
        let randomName = randomString(length: 10)
        let storageRef = Storage.storage().reference().child("savedimage\(randomName)")
        
        if let uploadData = UIImagePNGRepresentation(image) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    if let error = error {
                        print(error)
                    }
                }
                
                if let metadataURL = metadata?.downloadURL()?.absoluteString {
                    history.savedImageURL = metadataURL
                }
                
                let values: [String: Any] = ["addedDateTime": history.addedDateTime, "type": history.type, "result": history.result, "savedImageURL": history.savedImageURL]
                
                insertHistoryToRef(values: values, uid: uid)
                completionHandler()
            })
        }
    }
    
    static func insertHistoryToRef(values: [String: Any], uid: String) {
        let databaseRef = Database.database().reference()
        let usersRef = databaseRef.child("users").child(uid)
        
        let historyRef = usersRef.child("histories")
        let newHistory = historyRef.childByAutoId()
        
        newHistory.setValue(values) { (error, ref) in
            if let error = error {
                print(error)
            }
        }
    }
}
