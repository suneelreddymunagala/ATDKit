//
//  VariantData.swift
//  TDKit
//
//  Created by Suneel on 20/07/22.
//

import Foundation


// MARK: - VariantData
struct TDVariantAndLangaugeData: Codable {
    let languageDetails: [LanguageDetail]
    let variantDetails: VariantDetails

    enum CodingKeys: String, CodingKey {
        case languageDetails = "language_details"
        case variantDetails = "variant_details"
    }
}

// MARK: - LanguageDetail
struct LanguageDetail: Codable {
    let languageID: Int
    let language: String
    let order: Int

    enum CodingKeys: String, CodingKey {
        case languageID = "language_id"
        case language, order
    }
}

// MARK: - VariantDetails
struct VariantDetails: Codable {
    let petrol, diesel: FuelModes

    enum CodingKeys: String, CodingKey {
        case petrol = "Petrol"
        case diesel = "Diesel"
    }
}

// MARK: - BIFuelWithCNG
struct FuelModes: Codable {
    let automatic, manual: [TransmissionDetails]

    enum CodingKeys: String, CodingKey {
        case automatic = "Automatic"
        case manual = "Manual"
    }
}

// MARK: - Automatic
struct TransmissionDetails: Codable {
    let variantName: String
    let variantID: Int

    enum CodingKeys: String, CodingKey {
        case variantName = "variant_name"
        case variantID = "variant_id"
    }
}


//struct VariantData: Codable {
//    let languageDetails: [LanguageDetail]
//    let variantDetails: VariantDetails
//
//    enum CodingKeys: String, CodingKey {
//        case languageDetails = "language_details"
//        case variantDetails = "variant_details"
//    }
//}
//
//
//struct LanguageDetail: Codable {
//    let languageID: Int
//    let language: String
//    let order: Int
//
//    enum CodingKeys: String, CodingKey {
//        case languageID = "language_id"
//        case language, order
//    }
//}
//
//
//struct VariantDetails: Codable {
//    let petrol, biFuelWithCNG, diesel: Modes
//
//    enum CodingKeys: String, CodingKey {
//        case petrol = "Petrol"
//        case  biFuelWithCNG = "BiFuel with CNG"
//        case diesel = "Diesel"
//    }
//}
//
//
//struct Modes: Codable {
//    let automatic, manual: [Details]
//
//    enum CodingKeys: String, CodingKey {
//        case automatic = "Automatic"
//        case manual = "Manual"
//    }
//}
//
//
//struct Details: Codable {
//    let variantName: String
//    let variantID: Int
//
//    enum CodingKeys: String, CodingKey {
//        case variantName = "variant_name"
//        case variantID = "variant_id"
//    }
//}
