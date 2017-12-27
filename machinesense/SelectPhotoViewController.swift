//
//  SelectPhotoViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 27/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import SVProgressHUD

class SelectPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var selectedPhotoImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    var isSelectedPhoto = false
    var selectedPhotoData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        hideDimmingView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addPhotoAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func recognizePhotoAction(_ sender: Any) {
        if isSelectedPhoto {
            SVProgressHUD.show()
            selectedPhotoData = UIImagePNGRepresentation(selectedPhotoImageView.image!)
            recognizeObject(data: selectedPhotoData!, completionHandler: { (identifier, confidence) in
                DispatchQueue.main.async {
                    self.resultLabel.text = "\(identifier), with confidence: \(confidence)"
                    SVProgressHUD.dismiss()
                }
            })
        } else {
            showAlertMessage(vc: self, title: "Process Failed", message: "Please select photo from photos library on your phone")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedPhotoImageView.image = image
        isSelectedPhoto = true
        picker.dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showDimmingView(enableInteraction: Bool = false) {
        self.dimmingView.isHidden = false
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        self.view.isUserInteractionEnabled = enableInteraction
    }
    func hideDimmingView() {
        self.dimmingView.isHidden = true
        self.activityIndicatorView.isHidden = true
        self.activityIndicatorView.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
}
