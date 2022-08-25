//
//  TriggerData.swift
//  TDKit
//
//  Created by Suneel on 20/07/22.
//

import Foundation

// MARK: - FeaturesData
struct TDCarAndTriggerData: Codable {
    let carData: FeatureCarData
    let featureData: [TriggerDetails]
    let language: String

    enum CodingKeys: String, CodingKey {
        case carData = "car_data"
        case featureData = "feature_data"
        case language
    }
}

// MARK: - CarData
struct FeatureCarData: Codable {
    let carName: String
    let carID: Int

    enum CodingKeys: String, CodingKey {
        case carName = "car_name"
        case carID = "car_id"
    }
}

// MARK: - FeatureDatum
struct TriggerDetails: Codable {
    let isMarketingTrigger: Bool
    let audioFile: [String]
    let featureImageFile, triggerName: String
    let fuelType: FuelType
    let variant: String
    let feature: String
    let order: Int
    
    var isAudioPlayed: Bool? = false //custom data

    enum CodingKeys: String, CodingKey {
        case isMarketingTrigger = "is_marketing_trigger"
        case audioFile = "audio_file"
        case featureImageFile = "feature_image_file"
        case triggerName = "trigger"
        case fuelType = "fuel_type"
        case variant, feature, order
        
        case isAudioPlayed = "isAudioPlayed"
    }
}

enum FuelType: String, Codable {
    case petrol = "Petrol"
    case diesel = "Diesel"
}

enum Variant: String, Codable {
    case magna = "Magna"
}
