//
//  VCManager.swift
//  TDKit
//
//  Created by Suneel on 21/07/22.
//

import UIKit

class TDVCManager {
    
    static let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
static func openCustomerDetailsVC() -> TDCustomerDetailsVC? {
    guard let customerVC = storyBoard.instantiateViewController(withIdentifier: "TDCustomerDetailsVC") as? TDCustomerDetailsVC else { return nil}
    return customerVC
}


static func openVariantDetailsVC() -> TDVariantDetailsVC? {

    let bundle = Bundle(for: TDVariantDetailsVC.self)
    let tdStoryBoard = UIStoryboard(name: "Main", bundle: bundle)
    guard let tdVC = tdStoryBoard.instantiateViewController(withIdentifier: String(describing: TDVariantDetailsVC.self)) as? TDVariantDetailsVC else {
        return nil
    }
    return tdVC
}


static func openTriggerVC() -> TDTriggerDetailsVC? {
    
    let bundle = Bundle(for: TDVariantDetailsVC.self)
    let tdStoryBoard = UIStoryboard(name: "Main", bundle: bundle)
    guard let vc = tdStoryBoard.instantiateViewController(withIdentifier: "TDTriggerDetailsVC") as? TDTriggerDetailsVC else { return nil}
    return vc
}
    
}
