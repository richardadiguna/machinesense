//
//  TakePhotoViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 25/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import AVKit
import Vision
import CoreML

class TakePhotoViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var capturePreviewView: UIView!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var captureButton: UIButton!

    let cameraController = CameraController()
    
    
    
    var capturedData: Data?
    var resultIdentifier: String?
    var resultConfidence: VNConfidence?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCameraController()
        configureCaptureButtonStyle()
        
        let captureTapGesture = UITapGestureRecognizer(target: self, action: #selector(autoFocusGesture(gesture:)))
        captureTapGesture.numberOfTapsRequired = 1
        capturePreviewView.addGestureRecognizer(captureTapGesture)
    }
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            try? self.cameraController.displayPreview(on: self.capturePreviewView, superView: self.view)
        }
    }
    
    func configureCaptureButtonStyle() {
        captureButton.layer.borderColor = UIColor.gray.cgColor
        captureButton.layer.borderWidth = 2
        captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
    }
    
    @IBAction func captureImageAction(_ sender: Any) {
        cameraController.captureImage { (image, error) in
            if let error = error {
                print(error)
            } else {
                recognizeObject(data: image!, completionHandler: { (identifier, confidence) in
                    self.capturedData = image
                    self.resultIdentifier = identifier
                    self.resultConfidence = confidence
                })
                self.performSegue(withIdentifier: "goToCatpuredImage", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCatpuredImage" {
            let vc = segue.destination as! CapturedImageViewController
            vc.resultIdentifier = self.resultIdentifier
            vc.resultCondfidence = self.resultConfidence
            vc.capturedData = self.capturedData
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func switchCameraAction(_ sender: Any) {
        do {
            try cameraController.switchCamera()
        } catch {
            print(error)
        }
    }
    
    @objc func autoFocusGesture(gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: capturePreviewView)
        let convertedPoint = cameraController.previewLayer?.captureDevicePointConverted(fromLayerPoint: touchPoint)
        
        guard let currentCameraPosition = cameraController.currentCameraPosition else { return }
        switch currentCameraPosition {
        case .front:
            guard let frontCameraDevice = cameraController.frontCamera else { return }
            autoFocusDeviceConfiguration(device: frontCameraDevice, convertedPoint: convertedPoint!)
        case .rear:
            guard let rearCameraDevice = cameraController.rearCamera else { return }
            autoFocusDeviceConfiguration(device: rearCameraDevice, convertedPoint: convertedPoint!)
        }
    }
    
    func autoFocusDeviceConfiguration(device: AVCaptureDevice, convertedPoint: CGPoint) {
        try? device.lockForConfiguration()
        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = convertedPoint
            device.focusMode = .autoFocus
        }
        if device.isExposurePointOfInterestSupported {
            device.exposurePointOfInterest = convertedPoint
            device.exposureMode = .autoExpose
        }
        device.unlockForConfiguration()
    }
}

extension TakePhotoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
}
