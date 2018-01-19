//
//  FindObjectViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 28/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import Vision

class TextDetectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var textDetectionTextView: UITextView!
    
    let imagePicker = UIImagePickerController()
    
    var capturedData: Data?
    
    var observationResult: [VNTextObservation?]?
    
    var detectedText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextDetectionTextView()
        
        imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupTextDetectionTextView()
    }
    
    func setupTextDetectionTextView() {
        guard let detectedText = detectedText else { return }
        
        textDetectionTextView.text = detectedText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTextDetectionTextView() {
        let textStringAttr: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let textViewAttributtedString = NSMutableAttributedString(string: "MachineSense", attributes: textStringAttr)
        textDetectionTextView.attributedText = textViewAttributtedString
    }

    @IBAction func selectPhotoAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func takePhotoAction(_ sender: Any) {
        performSegue(withIdentifier: "textDetectionCaptureSegue", sender: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let resizedImage = image.resizeImage(newSize: self.view.frame.size)
        capturedData = UIImagePNGRepresentation(resizedImage)
        picker.dismiss(animated: true) {
            self.startDetectText(selectedImage: resizedImage)
            self.performSegue(withIdentifier: "goToPlotTextSegue", sender: self)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlotTextSegue" {
            let vc = segue.destination as! PlotTextViewController
            vc.observationResult = self.observationResult
            vc.capturedData = self.capturedData
        }
    }
    
    func startDetectText(selectedImage: UIImage) {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        textRequest.reportCharacterBoxes = true
        
        let selectedData = UIImagePNGRepresentation(selectedImage)
        
        try? VNImageRequestHandler(data: selectedData!, options: [:]).perform([textRequest])
    }
    
    func detectTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else { return }
        let result = observations.map({$0 as? VNTextObservation})
        self.observationResult = result as [VNTextObservation?]
    }
    
    @IBAction func unwindToTextDetectionViewController(segue: UIStoryboardSegue) { }
}
