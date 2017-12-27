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
}
