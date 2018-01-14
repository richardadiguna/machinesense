//
//  CaptureView.swift
//  machinesense
//
//  Created by Richard Adiguna on 13/01/18.
//  Copyright © 2018 Richard Adiguna. All rights reserved.
//

import UIKit

class CaptureView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var capturePhotoButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    
    var delegate: CaptureViewDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        Bundle.main.loadNibNamed("CaptureView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        configureCapturePhotoButton()
        configureActionButton()
    }
    
    func configureCapturePhotoButton() {
        capturePhotoButton.layer.borderColor = UIColor.gray.cgColor
        capturePhotoButton.layer.borderWidth = 2
        capturePhotoButton.layer.cornerRadius = min(capturePhotoButton.frame.width, capturePhotoButton.frame.height) / 2
    }
    
    func configureActionButton() {
        capturePhotoButton.addTarget(self, action: #selector(self.capturePhoto), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(self.switchCamera), for: .touchUpInside)
    }
    
    @objc func capturePhoto() {
        guard let delegate = delegate else { return }
        delegate.capturePhoto()
    }
    
    @objc func switchCamera() {
        guard let delegate = delegate else { return }
        delegate.switchCamera()
    }
}

protocol CaptureViewDelegate {
    func capturePhoto()
    func switchCamera()
}
