//
//  CameraController.swift
//  machinesense
//
//  Created by Richard Adiguna on 25/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import AVKit

class CameraController: NSObject {
    
    var rearCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureVideoDataOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var photoCaptureCompletionBlock: ((Data?, Error?) -> Void)?
    var videoCaptureCompletionBlock: ((CVPixelBuffer?, Error?) -> Void)?
    
    func createCaptureSession() {
        captureSession = AVCaptureSession()
    }
    
    func configureCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        
        let cameras = session.devices.flatMap({$0})
        guard !cameras.isEmpty else {
            print("Something", #line)
            throw CameraControllerError.noCamerasAvailable
        }
        
        for camera in cameras {
            if camera.position == .front {
                frontCamera = camera
            }
            if camera.position == .back {
                rearCamera = camera
                
                try? camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
    }
    
    func configureDeviceInputs() throws {
        guard let captureSession = captureSession else {
            print("Something", #line)
            throw CameraControllerError.captureSessionIsMissing
        }
        
        if let rearCamera = rearCamera {
            rearCameraInput = try? AVCaptureDeviceInput(device: rearCamera)
            
            if captureSession.canAddInput(rearCameraInput!) {
                captureSession.addInput(rearCameraInput!)
            } else {
                print("Something", #line)
                throw CameraControllerError.inputsAreInvalid
            }
            
            currentCameraPosition = .rear
        } else if let frontCamera = frontCamera {
            frontCameraInput = try? AVCaptureDeviceInput(device: frontCamera)
            
            if captureSession.canAddInput(frontCameraInput!) {
                captureSession.addInput(frontCameraInput!)
            } else {
                print("Something", #line)
                throw CameraControllerError.inputsAreInvalid
            }
            
            currentCameraPosition = .front
        }
    }
    
    func configurePhotoOutput() throws {
        guard let captureSession = captureSession else {
            print("Something", #line)
            throw CameraControllerError.captureSessionIsMissing
        }
        
        photoOutput = AVCapturePhotoOutput()
        photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        
        if captureSession.canAddOutput(photoOutput!) {
            captureSession.addOutput(photoOutput!)
        }
        captureSession.startRunning()
    }
    
    func configureVideoOutput() throws {
        guard let captureSession = captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput!)
    }
    
    func prepare(completionHandler: @escaping (Error?)->Void) {
        DispatchQueue(label: "prepare").sync {
            do {
                print("Something", #line)
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configureVideoOutput()
                try configurePhotoOutput()
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView, superView: UIView) throws {
        guard let captureSession = captureSession, captureSession.isRunning else {
            print("Something", #line)
            throw CameraControllerError.captureSessionIsMissing
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = superView.frame
    }
    
    func captureImage(completion: @escaping (Data?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        photoCaptureCompletionBlock = completion
    }
    
    func captureVideo(completion: @escaping (CVPixelBuffer?, Error?)->Void) {
        guard let captureSession = captureSession, captureSession.isRunning else {
            completion(nil, CameraControllerError.captureSessionIsMissing)
            return
        }
        videoCaptureCompletionBlock = completion
    }
    
    func switchToFrontCamera() throws {
        guard let captureSession = captureSession else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        guard let rearCameraInput = rearCameraInput else {
            throw CameraControllerError.invalidOperation
        }
        
        guard captureSession.inputs.contains(rearCameraInput), let frontCamera = frontCamera else {
            throw CameraControllerError.inputsAreInvalid
        }
        
        frontCameraInput = try? AVCaptureDeviceInput(device: frontCamera)
        
        captureSession.removeInput(rearCameraInput)
        
        if captureSession.canAddInput(frontCameraInput!) {
            captureSession.addInput(frontCameraInput!)
            
            currentCameraPosition = .front
        } else {
            throw CameraControllerError.invalidOperation
        }
    }
    
    func switchToRearCamera() throws {
        guard let captureSession = captureSession else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        guard let frontCameraInput = frontCameraInput else {
            throw CameraControllerError.invalidOperation
        }
        
        guard captureSession.inputs.contains(frontCameraInput), let rearCamera = rearCamera else {
            throw CameraControllerError.inputsAreInvalid
        }
        
        rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
        
        captureSession.removeInput(frontCameraInput)
        
        if captureSession.canAddInput(rearCameraInput!) {
            captureSession.addInput(rearCameraInput!)
            
            currentCameraPosition = .rear
        } else {
            throw CameraControllerError.invalidOperation
        }
    }
    
    func switchCamera() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = captureSession else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        captureSession.beginConfiguration()
        
        switch currentCameraPosition {
        case .front:
            try? switchToRearCamera()
        case .rear:
            try? switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
    deinit {
        print("Deinitialize CameraController")
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            photoCaptureCompletionBlock?(nil, error)
        } else if let data = photo.fileDataRepresentation() {
            let _ = UIImage(data: data)
            self.photoCaptureCompletionBlock?(data, nil)
        } else {
            photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        videoCaptureCompletionBlock?(pixelBuffer, nil)
    }
    
}
