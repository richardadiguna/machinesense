//
//  Enum.swift
//  machinesense
//
//  Created by Richard Adiguna on 25/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit

enum CategoryType: Int {
    case SelectPhoto = 0
    case TakePhoto = 1
    case VideoTracking = 2
    case FindObject = 3
    case `default` = 4
    
    var localDescription: String {
        switch self {
        case .SelectPhoto:
            return "Select Photo"
        case .TakePhoto:
            return "Take Photo"
        case .VideoTracking:
            return "Video Tracking"
        case .FindObject:
            return "Find Object"
        default:
            return ""
        }
    }
    
    var localColorDescription: UIColor {
        switch self {
        case .SelectPhoto:
            return UIColor(red: 0/255, green: 84/255, blue: 146/255, alpha: 1)
        case .TakePhoto:
            return UIColor(red: 2/255, green: 106/255, blue: 107/255, alpha: 1)
        case .VideoTracking:
            return UIColor(red: 238/255, green: 61/255, blue: 60/255, alpha: 1)
        case .FindObject:
            return UIColor(red: 253/255, green: 154/255, blue: 34/255, alpha: 1)
        default:
            return UIColor.white
        }
    }
}

public enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}

public enum CameraPosition {
    case front
    case rear
}
