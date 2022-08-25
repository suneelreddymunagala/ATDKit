//
//  Extension+Alert.swift
//  TDKit
//
//  Created by Suneel on 22/07/22.
//

import UIKit

extension UIViewController {
    func showAlert(message: String, viewController: UIViewController) {
        let alertVC = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertVC.addAction(okAction)
        viewController.present(alertVC, animated: true, completion: nil)
    }

}

