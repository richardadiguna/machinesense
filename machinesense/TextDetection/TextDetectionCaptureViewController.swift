//
//  TextDetectionCaptureViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 13/01/18.
//  Copyright © 2018 Richard Adiguna. All rights reserved.
//

import UIKit
import Vision

class TextDetectionCaptureViewController: UIViewController {

    @IBOutlet weak var textDetectionCaptureView: CaptureView!
    
    let cameraController = CameraController()
    
    var requests: [VNRequest]?
    
    var observationResult: [VNTextObservation?]?
    var capturedData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.configureCameraController()
        }
        
        textDetectionCaptureView.delegate = self
        // Do any additional setup after loading the view.
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
    
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            try? self.cameraController.displayPreview(on: self.textDetectionCaptureView.captureView, superView: self.view)
        }
    }
}

extension TextDetectionCaptureViewController: CaptureViewDelegate {
    
    func capturePhoto() {
        cameraController.captureImage { (data, error) in
            guard let data = data else { return }
            if let error = error {
                print(error)
            } else {
                let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
                textRequest.reportCharacterBoxes = true
                self.requests = [textRequest]
                self.capturedData = data
                try? VNImageRequestHandler(data: data, options: [:]).perform(self.requests!)
                
                self.performSegue(withIdentifier: "goToPlotTextSegue", sender: self)
            }
        }
    }
    
    func detectTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else { return }
        let result = observations.map({$0 as? VNTextObservation})
        self.observationResult = result as [VNTextObservation?]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlotTextSegue" {
            let vc = segue.destination as! PlotTextViewController
            vc.capturedData = self.capturedData
            vc.observationResult = self.observationResult
        }
    }
    
    
    func switchCamera() {
        do {
            try cameraController.switchCamera()
        } catch {
            print(error)
        }
    }
    
}
