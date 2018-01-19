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

extension UIImage {
    
    func resizeImage(newSize: CGSize) -> UIImage {
        let widthRatio = newSize.width / size.width
        let heighRatio = newSize.height / size.height
        
        var newSize: CGSize {
            if widthRatio > heighRatio {
                return CGSize(width: size.width * heighRatio, height: size.height * heighRatio)
            } else {
                return CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage ?? UIImage()
    }
    
}
