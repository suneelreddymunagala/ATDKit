//
//  GDMSAppDealerData.swift
//  TDKit
//
//  Created by Suneel on 21/07/22.
//

import Foundation

struct GDMSAppData: Codable {

    let tdId: String
    let customerId: String
    let dealerNumber: String
    
    internal init(tdId: String, customerId: String, dealerNumber: String) {
        self.tdId = tdId
        self.customerId = customerId
        self.dealerNumber = dealerNumber
    }
}
