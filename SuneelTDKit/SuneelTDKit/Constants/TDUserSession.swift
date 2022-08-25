//
//  TDUserSession.swift
//  TDKit
//
//  Created by Suneel on 21/07/22.
//

import Foundation


struct TDUserSession {
    static var GDMS_APP_TD_DATA: GDMSAppData? {
        get {
            guard let data = UserDefaults.standard.retrieve(object: GDMSAppData.self, fromKey: "GDMSAppDealerDetails") else {
                return nil
            }
            return data
        } set {
            guard newValue != nil else {
                UserDefaults.standard.removeObject(forKey: "GDMSAppDealerDetails")
                return
            }
            //encodedata
            UserDefaults.standard.save(customObject:newValue, inKey: "GDMSAppDealerDetails")
        }
    }
}
