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
    
    var addedDate: Date?
    var type: CategoryType?
    var data: Data?
    var result: String?
    
    required init() {
        
    }
    
    convenience init(addedDate: Date, type: CategoryType, data: Data, result: String) {
        self.init()
        self.addedDate = addedDate
        self.type = type
        self.data = data
        self.result = result
    }
    
    // Need complete this function
    public static func fetchAllHistory(by id: String) -> [History] {
        return [History()]
    }
    
}
