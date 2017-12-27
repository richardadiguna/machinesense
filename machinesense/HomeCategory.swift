//
//  HomeCategory.swift
//  machinesense
//
//  Created by Richard Adiguna on 25/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import Foundation
import RealmSwift

class HomeCategory: Object {
    
    @objc dynamic var type = CategoryType.default.rawValue
    
    var typeEnum: CategoryType {
        get {
            return CategoryType(rawValue: type)!
        }
        set {
            type = newValue.rawValue
        }
    }
}

