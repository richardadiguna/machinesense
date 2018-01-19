//
//  Global.swift
//  machinesense
//
//  Created by Richard Adiguna on 25/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import Foundation
import RealmSwift
import Vision
import CoreML
import Firebase

func getSomeObjects<T>(object: T.Type) -> [T]? {
    let config = Realm.Configuration(fileURL: Bundle.main.url(forResource: "Persistent", withExtension: "realm"), readOnly: true)
    let realm = try! Realm(configuration: config)
    let objects = realm.objects(object as! Object.Type).toArray(ofType: object) as [T]
    return objects.count > 0 ? objects : nil
}

func recognizeObject(data: Data, completionHandler: @escaping (_ identifier: String, _ confidence: VNConfidence)->Void) {
    guard let model = try? VNCoreMLModel(for: MobileNet().model) else { return }
    
    let request = VNCoreMLRequest(model: model, completionHandler: { (finishedRequest, error) in
        
        guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
        guard let firstObservation = results.first else { return }
        
        let identifier = firstObservation.identifier
        let confidence = firstObservation.confidence
        completionHandler(identifier, confidence)
    })
    try? VNImageRequestHandler(data: data, options: [:]).perform([request])
}

func showAlertMessage(vc: UIViewController, title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(defaultAction)
    vc.present(alertController, animated: true, completion: nil)
}

func showAlertMessage(vc: UIViewController, title: String, message: String, completion: @escaping ()->Void) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
        completion()
    }
    alertController.addAction(defaultAction)
    vc.present(alertController, animated: true, completion: nil)
}

func randomString(length: Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

