//
//  User.swift
//  machinesense
//
//  Created by Richard Adiguna on 22/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import Foundation
import FirebaseAuth

class User {
    
    fileprivate var firstName_: String
    fileprivate var lastName_: String
    fileprivate var email_: String
    
    init(firstName: String, lastName: String, email: String) {
        self.firstName_ = firstName
        self.lastName_ = lastName
        self.email_ = email
    }
    
    var firstName: String {
        get {
            return firstName_
        }
        set {
            firstName_ = newValue
        }
    }
    
    var lastName: String {
        get {
            return lastName_
        }
        set {
            lastName_ = newValue
        }
    }
    
    var fullName: String {
        get {
            let name = firstName_ + lastName
            return name
        }
    }
    
    var email: String {
        get {
            return email_
        }
        set {
            email_ = newValue
        }
    }
    
    static var uid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    public static func loginUser() {
        
    }
    
    public static func logoutUser(completion: @escaping ()->Void) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                completion()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
}
