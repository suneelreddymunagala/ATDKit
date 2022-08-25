//
//  TestDriveData.swift
//  TDKit
//
//  Created by Suneel on 12/08/22.
//

import Foundation


// MARK: - TestDriveData
public struct TestDriveData: Codable {
    let tstdrvID, dlrNo: String
    let responseData: ResponseData

    enum CodingKeys: String, CodingKey {
        case tstdrvID = "tstdrvId"
        case dlrNo, responseData
    }
}

// MARK: - ResponseData
public struct ResponseData: Codable {
    let triggerDetails: [TriggerDetail]
    let activity, testdriveStart, testdriveEnd, carModel: String
    let testdriveDuration, language, fualType, transmissionType: String
   
    enum CodingKeys: String, CodingKey {
        case triggerDetails = "trigger_details"
        case activity
        case testdriveStart = "testdrive_start"
        case testdriveEnd = "testdrive_end"
        case carModel = "car_model"
        case testdriveDuration = "testdrive_duration"
        case language
        case fualType = "fual_type"
        case transmissionType = "transmission_type"
    }
}

// MARK: - TriggerDetail
public struct TriggerDetail: Codable {
    let triggerType, feature: String

    enum CodingKeys: String, CodingKey {
        case triggerType = "trigger_type"
        case feature
    }
}
