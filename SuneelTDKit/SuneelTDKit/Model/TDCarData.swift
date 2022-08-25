//
//  TDCarData.swift
//  TDKit
//
//  Created by Suneel on 20/07/22.
//

import Foundation

struct TDCarData: Codable {
    var carID: Int
    var order:Int
    var carName: String
    var gdmsCarName:String?
    var carlogoImageFile: String
    var carThumbnailImageFile:String
    var carDescriptionImageFile: String
    var carDetailsZipArray:[CarDetailsZipFile]
    
    var carLogoImageFileData: Data?
     var carThumbnailImageFileData: Data?
     var carDescriptionImageFileData: Data?
    
    
    enum CodingKeys: String, CodingKey {
        case carID = "car_id"
        case order = "order"
        case carName = "car_name"
        case gdmsCarName = "gdms_car_name"
        case carlogoImageFile = "car_logo_image_file"
        case carThumbnailImageFile = "car_thumbnail_image_file"
        case carDescriptionImageFile = "car_description_image_file"
        case carDetailsZipArray = "car_details_zip"
    }
}


struct CarDetailsZipFile: Codable {
    var carDetailsFile:String
    var assestSize: String
    enum CodingKeys: String, CodingKey {
        case carDetailsFile = "car_details_file"
        case assestSize = "file_size"
    }
}
