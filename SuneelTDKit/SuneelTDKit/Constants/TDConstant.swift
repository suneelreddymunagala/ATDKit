//
//  TDConstant.swift
//  TDKit
//
//  Created by Suneel on 21/07/22.
//

import Foundation
import UIKit

let assetsDataError = "Sorry! No Data to dispaly. Go to SETTINGS and download Data"
let restoreAlertTitle = "Please download test drive assests from settings and try again later"


let obdConnectionError = "Check your OBD device Connection or Check your bluetooth permission in Settings"
let enableBluetoothMessage = "Enable Bluetooth"
let bluetoothPermissionMessage = "Allow bluetooth permission"
let noDataErrorMessage = "Please check device connection/Turn on the car and Connect"

let openSettingsText = "Open Settings"

let WELCOME_MESSAGE_TRIGGER = "Welcome Message"
let END_MESSAGE_TRIGGER  = "End message"


let ENGINE_IDLING_TRIGGERS = "engineIdlingTriggers"
let ENGINE_PICKUP_TRIGGERS = "enginePickupTriggers"
let SOFT_BRAKE_TRIGGERS = "softBrakeTriggers"
let SMOOTH_ACCELERATION_TRIGGERS = "smoothAcceleration"
let CRUISE_CONTROLTYPE_TRIGGERS = "cruisecontroltypetriggers"




 let TD_BUNDLE = Bundle(identifier: "com.apprikart.TDKit")

struct TDColorCode {
    
    static let lightGrey = UIColor(red: 38/255, green: 39/255, blue: 44/255, alpha: 1.0)
    
    static let primaryColor = UIColor(red: 101/255, green: 127/255, blue: 188/255, alpha: 1.0)
    
}

struct TDImage {
    
     let tdBundle = Bundle(identifier: "com.apprikart.TDKit")
    
    
    static func getunSelectImage() -> UIImage? {
        guard let tdBundle = Bundle(identifier: "com.apprikart.TDKit") else { return nil }
        
        guard let image = tdBundle.path(forResource: "UnSelect", ofType: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: image)
    }
    
    
    static func getSelectedImage() -> UIImage? {
        guard let tdBundle = Bundle(identifier: "com.apprikart.TDKit") else { return nil }
        
        guard let image = tdBundle.path(forResource: "selected", ofType: "png") else {
            return nil
        }
        return UIImage(contentsOfFile: image)
    }
    
    
}


struct TDColorCodes {
    static let primaryColor = UIColor(red: 101/255, green: 127/255, blue: 188/255, alpha: 1.0)
}
