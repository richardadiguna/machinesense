//
//  ObjectTrackingViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 28/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import AVKit
import Vision
import CoreML

class ObjectTrackingViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var capturePreviewView: UIView!
    
    let highlightView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.red.cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    let cameraController = CameraController()
    
    fileprivate let visionSequenceHandler = VNSequenceRequestHandler()
    fileprivate var lastObservation: VNDetectedObjectObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCameraController()
        
        self.view.addSubview(highlightView)
        
        let userTapGesture = UITapGestureRecognizer(target: self, action: #selector(userTapped(gesture:)))
        userTapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(userTapGesture)
        
        cameraController.captureVideo { (pixelBuffer, error) in
            if let error = error {
                print(error)
            }
            guard let pixelBuffer = pixelBuffer, let lastObservation = self.lastObservation else {
                return
            }
            let request = VNTrackObjectRequest(detectedObjectObservation: lastObservation, completionHandler: self.handleVisionRequestUpdate)
            request.trackingLevel = .accurate
            
            try? self.visionSequenceHandler.perform([request], on: pixelBuffer)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func configureCameraController() {
        cameraController.prepare { (error) in
            if let error = error {
                print(error)
            }
            try? self.cameraController.displayPreview(on: self.capturePreviewView, superView: self.view)
        }
    }
    
    @objc func userTapped(gesture: UITapGestureRecognizer) {
        highlightView.frame.size = CGSize(width: 180, height: 180)
        highlightView.center = gesture.location(in: self.view)
        
        let originalRect = highlightView.frame
        guard let previewLayer = cameraController.previewLayer else { return }
        
        var convertedRect = previewLayer.metadataOutputRectConverted(fromLayerRect: originalRect)
        convertedRect.origin.y = 1 - convertedRect.origin.y
        
        let newObservation = VNDetectedObjectObservation(boundingBox: convertedRect)
        self.lastObservation = newObservation
    }
    
    private func handleVisionRequestUpdate(_ request: VNRequest, error: Error?) {
        // Dispatch to the main queue because we are touching non-atomic, non-thread safe properties of the view controller
        DispatchQueue.main.async {
            guard let newObservation = request.results?.first as? VNDetectedObjectObservation else { return }
            self.lastObservation = newObservation
            
            guard newObservation.confidence >= 0.3 else {
                self.highlightView.frame = .zero
                return
            }
            
            var transformedRect = newObservation.boundingBox
            transformedRect.origin.y = 1 - transformedRect.origin.y
            
            guard let previewLayer = self.cameraController.previewLayer else { return }
            
            let convertedRect = previewLayer.layerRectConverted(fromMetadataOutputRect: transformedRect)
            self.highlightView.frame = convertedRect
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchCameraAction(_ sender: Any) {
        do {
            try cameraController.switchCamera()
        } catch {
            print(error)
        }
    }
    
    @IBAction func shutterButtonAction(_ sender: Any) {
    }
}
