//
//  CapturedImageViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 26/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import Vision
import Firebase
import MBProgressHUD

class CapturedImageViewController: UIViewController {

    var capturedData: Data?
    var resultIdentifier: String?
    var resultCondfidence: VNConfidence?
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var capturedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterfaceComponent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveResult(_ sender: Any) {
        DispatchQueue.main.async {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Uploading..."
        }
        
        guard let capturedImage = capturedImageView.image else { print("Failed");return }
        let uid = User.uid
        
        let addedDateTime = Date()
        let result = resultLabel.text
        let type = CategoryType.TakePhoto.rawValue
        
        let history = History(addedDateTime: addedDateTime, type: type, result: result!)
        History.saveHistoryWithImage(history, image: capturedImage, uid: uid) {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            showAlertMessage(vc: self, title: "Uploading Complete", message: "Your Data has been stored to the cloud", completion: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    
    func configureInterfaceComponent() {
        if resultIdentifier != nil && resultCondfidence != nil {
            guard let resultIdentifier = resultIdentifier, let resultConfidence = resultCondfidence else { return }
            resultLabel.text = "\(resultIdentifier), with confidence: \(resultConfidence)"
        }
        capturedImageView.image = changeDataToImage(data: capturedData)
    }
    
    func changeDataToImage(data: Data?) -> UIImage? {
        guard let data = data else { print(#function); return nil }
        print("sukses")
        let image = UIImage(data: data)
        
        return image
    }
}
