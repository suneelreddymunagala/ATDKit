//
//  TDLogData.swift
//  TDKit
//
//  Created by Suneel on 20/07/22.
//

import Foundation


struct TDLogData: Codable {
    let result: Result
    let errors: Errors
}

// MARK: - Errors
struct Errors: Codable {
    let errorDesc, errorMsg: String
}

// MARK: - Result
struct Result: Codable {
    let result: String
}
