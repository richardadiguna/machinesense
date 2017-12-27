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
    
    @IBAction func saveImageAction(_ sender: Any) {
        
    }
    
    @IBAction func closePreviewAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureInterfaceComponent() {
        if resultIdentifier != nil && resultCondfidence != nil {
            guard let resultIdentifier = resultIdentifier, let resultConfidence = resultCondfidence else { return }
            resultLabel.text = "\(resultIdentifier), with confidence: \(resultConfidence)"
        }
        capturedImageView.image = changeDataToImage(data: capturedData)
    }
    
    func changeDataToImage(data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        
        let image = UIImage(data: data)
        
        return image
    }
}
