//
//  RealTimeRecogViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 26/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import AVKit
import Vision
import CoreML

class RealTimeRecogViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var inputImage: CIImage?
    
    var recognizedWords: [String] = []
    var recognizedRegion: String = ""
    
    lazy var ocrRequest: VNCoreMLRequest = {
        let model = try? VNCoreMLModel(for: OCR().model)
        return VNCoreMLRequest(model: model!, completionHandler: self.handleClassification)
    }()
    
    lazy var textDetectionRequest: VNDetectTextRectanglesRequest = {
        return VNDetectTextRectanglesRequest(completionHandler: self.handleDetection)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // AVCaptureSession is use for show up the camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }

        captureSession.addInput(input)
        captureSession.startRunning()

        // Preview layer is use for add the AV to the view in ViewController
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame

        // Camera data output monitor
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        captureSession.addOutput(dataOutput)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Capture every frame that being capture
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // Sample buffer is a frame that being captured by the camera
        // pixelBuffer get raw data from the sample buffer
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Initialize the model using CoreML Model
        guard let model = try? VNCoreMLModel(for: MobileNet().model) else { return }

        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in

            // Check the error

            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }

            guard let firstObservation = results.first else { return }

            print(firstObservation.identifier, firstObservation.confidence)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    func handleDetection(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNTextObservation]
            else {fatalError("unexpected result") }
        
        let transform = CGAffineTransform.identity.scaledBy(x: (self.inputImage?.extent.size.width)!, y: (self.inputImage?.extent.size.height)!)
        
        self.recognizedWords = []
        
        for region in observations {
            guard let boxesIn = region.characterBoxes else { continue }
            
            self.recognizedRegion = ""
            
            for box in boxesIn {
                let realBoundingBox = box.boundingBox.applying(transform)
                
                guard (inputImage?.extent.contains(realBoundingBox))! else { print("invalid detected rectangle"); return }
                
                // Scale the points to pixels
                let topLeft = box.topLeft.applying(transform)
                let topRight = box.topRight.applying(transform)
                let bottomLeft = box.bottomLeft.applying(transform)
                let bottomRight = box.bottomRight.applying(transform)
                
                // Crop and rectify image
                let charImage = inputImage?.cropped(to: realBoundingBox).applyingFilter("CIPerspectiveCorrection", parameters: [
                    "inputTopLeft": CIVector(cgPoint: topLeft),
                    "inputTopRight": CIVector(cgPoint: topRight),
                    "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                    "inputBottomRight": CIVector(cgPoint: bottomRight)
                    ])
                
                ocrRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFill
                
                try? VNImageRequestHandler(ciImage: charImage!, options: [:]).perform([self.ocrRequest])
            }
            self.recognizedWords.append(recognizedRegion)
            
            DispatchQueue.main.async {
                print(self.recognizedWords)
            }
        }
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNClassificationObservation] else { fatalError("Unexpected Result")}
        guard let best = observations.first else { fatalError("Unexpected Result")}
        self.recognizedRegion = self.recognizedRegion.appending(best.identifier)
    }
    
    func runOCRProcess(ciImage: CIImage) {
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        self.textDetectionRequest.reportCharacterBoxes = true
        self.textDetectionRequest.preferBackgroundProcessing = false
        
        DispatchQueue.global(qos: .userInteractive).async {
            try? handler.perform([self.textDetectionRequest])
        }
    }
}
