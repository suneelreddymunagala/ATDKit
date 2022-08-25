//
//  TestDriveAssestsData.swift
//  TDKit
//
//  Created by Suneel on 20/07/22.
//

import Foundation

struct TestDriveAssestsData: Codable {
    var carName: String
    var carID: Int
    var assetFile: String?
    
    enum CodingKeys: String, CodingKey {
        case carName = "car_name"
        case carID = "car_id"
        case assetFile = "asset_file"
        
    }
}
