//
//  PlotTextViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 13/01/18.
//  Copyright © 2018 Richard Adiguna. All rights reserved.
//

import UIKit
import Vision
import TesseractOCR
import SVProgressHUD

class PlotTextViewController: UIViewController {
    
    @IBOutlet weak var capturedImageView: UIImageView!
    
    var observationResult: [VNTextObservation?]?
    var capturedData: Data?
    var capturedImage: UIImage?
    
    var recognizedWords: [String] = []
    var recognizedRegion: String = ""
    
    var tesseract: G8Tesseract!
    
    var isProcessOCR: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if capturedData != nil {
            capturedImage = convertDataToImage(data: capturedData)
            capturedImageView.image = capturedImage
            plotTextOnPhoto(observationResult: observationResult)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func nextAction(_ sender: Any) {
        guard let detectedText = runOCRProcess(capturedData: capturedData) else { return }
        
        self.performSegue(withIdentifier: "unwindToTextDetectionViewController", sender: detectedText)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToTextDetectionViewController" {
            let vc = segue.destination as! TextDetectionViewController
            let sender = sender as! String
            vc.detectedText = sender
        }
    }
    
    func convertDataToImage(data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        let image = UIImage(data: data)
        return image
    }
    
    func configureTesseract() {
        tesseract = G8Tesseract(language: "eng")
        tesseract.engineMode = .tesseractCubeCombined
        tesseract.pageSegmentationMode = .auto
    }
    
    func plotTextOnPhoto(observationResult: [VNTextObservation?]?) {
        guard let observationResult = observationResult else { return }
        
        DispatchQueue.main.async {
            self.capturedImageView.layer.sublayers?.removeSubrange(1...)
            
            for region in observationResult {
                guard let region = region else { continue }
                
                self.highlightWord(box: region)
            }
        }
    }
    
    func highlightWord(box: VNTextObservation) {
        guard let boxes = box.characterBoxes else { return }
        
        var maxX: CGFloat = CGFloat.greatestFiniteMagnitude
        var minX: CGFloat = 0
        var maxY: CGFloat = CGFloat.greatestFiniteMagnitude
        var minY: CGFloat = 0
        
        for char in boxes {
            if char.bottomLeft.x < maxX {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY {
                minY = char.topRight.y
            }
        }
        
        let xCord = maxX * capturedImageView.frame.size.width
        let yCord = (1 - minY) * capturedImageView.frame.size.height
        let width = (minX - maxX) * capturedImageView.frame.size.width
        let height = (minY - maxY) * capturedImageView.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 1
        outline.borderColor = UIColor.red.cgColor
        
        capturedImageView.layer.addSublayer(outline)
    }

}

extension PlotTextViewController {
    
    func runOCRProcess(capturedData: Data?) -> String? {
        configureTesseract()
        let image = convertDataToImage(data: capturedData)
        tesseract.image = image?.g8_blackAndWhite()
        tesseract.recognize()
        
        let detectedText = tesseract.recognizedText
        isProcessOCR = false
        return detectedText ?? ""
    }
}
