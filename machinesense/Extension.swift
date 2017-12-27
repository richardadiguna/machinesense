//
//  Extension.swift
//  machinesense
//
//  Created by Richard Adiguna on 22/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import RealmSwift

extension UITextField {
    
    func setPlaceHolderColor(color: UIColor) {
        let attrString = [NSAttributedStringKey.foregroundColor: color]
        
        guard let placeholder = placeholder else {
            return
        }
        self.attributedPlaceholder = NSMutableAttributedString(string: placeholder, attributes: attrString)
    }
}

extension Results {
    
    func toArray<T>(ofType: T.Type) -> [T] {
        var array: [T] = []
        for i in 0..<count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
    
}
