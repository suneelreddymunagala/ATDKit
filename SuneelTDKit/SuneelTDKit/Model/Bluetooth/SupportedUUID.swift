//
//  SupportedUUID.swift
//  TDKit
//
//  Created by Suneel on 26/07/22.
//

import Foundation
import CoreBluetooth

class SupportedPeripheral: NSObject {
    private static let FFF0 = CBUUID.init(string: "FFF0")
    private static let FFE0 = CBUUID.init(string: "FFE0")
    private static let BEEF = CBUUID.init(string: "BEEF")
    private static let E7810A71 = CBUUID.init(string: "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2")
    
    static func allUUIDs() -> [CBUUID] {
        return [self.FFF0, self.FFE0, self.BEEF, self.E7810A71]
    }
    
}
