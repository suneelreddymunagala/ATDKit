//
//  Extension+String.swift
//  TDKit
//
//  Created by Suneel on 20/07/22.
//

import Foundation
extension String {
    func queryString(params: [String: String]) -> String? {
        var components = URLComponents(string: self)
        components?.queryItems = params.map { element in URLQueryItem(name: element.key, value: element.value) }
        
        return components?.url?.absoluteString
    }
}
