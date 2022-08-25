//
//  TestDriveDetails.swift
//  TDKit
//
//  Created by Suneel on 12/08/22.
//

import Foundation

public class TDCustomerInfo {
    let address: String
    let tdId: Int
    let customerName: String
    let customerPhone: String
    let customerId: Int
    let customerEmail: String
    let testDriveDate: String
    let testDriveTime: String
    let carModel: String
    let dlrno: String
   
    public init(address: String, tdId: Int, customerName: String, customerPhone: String, customerId: Int, customerEmail: String, testDriveDate: String, testDriveTime: String, carModel: String, dlrno: String) {
        self.address = address
        self.tdId = tdId
        self.customerName = customerName
        self.customerPhone = customerPhone
        self.customerId = customerId
        self.customerEmail = customerEmail
        self.testDriveDate = testDriveDate
        self.testDriveTime = testDriveTime
        self.carModel = carModel
        self.dlrno = dlrno
    }
   
}


public protocol TestDriveDelegate {
    func didFinishTestDrive(testDrive: TestDriveData?, error: Error?)
    func didFailToGetTestDriveData(error: Error?)
}
