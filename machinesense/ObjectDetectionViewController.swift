//
//  FindObjectViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 28/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import Vision

class DetectObjectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var capturedPhotoImageView: UIImageView!
    
    let highlightView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.red.cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    let imagePicker = UIImagePickerController()
    var detectObservation: VNDetectedObjectObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectPhotoAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        highlightView.frame.size = CGSize(width: 120, height: 120)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        capturedPhotoImageView.image = image
        let imageData = UIImagePNGRepresentation(image)
        picker.dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
