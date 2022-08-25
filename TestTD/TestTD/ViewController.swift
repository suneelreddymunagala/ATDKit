//
//  ViewController.swift
//  TestTD
//
//  Created by Suneel on 24/08/22.
//

import UIKit
import SuneelTDKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.callTDAPI()
    }

    
    func callTDAPI() {
        let customerInfo = TDCustomerInfo(address: "New%20Delhi,%20DELH", tdId: 123, customerName: "IOS%20TEST", customerPhone: "9951343933", customerId: 1234, customerEmail: "iostest@gmail.com", testDriveDate: "29-12-2021", testDriveTime: "08:48%20PM", carModel: "HQ", dlrno: "NH001")
        let bundle = Bundle(for: TDCustomerDetailsVC.self)
        let tdStoryBoard = UIStoryboard(name: "Main", bundle: bundle)
        guard let tdVC = tdStoryBoard.instantiateViewController(withIdentifier: String(describing: TDCustomerDetailsVC.self)) as? TDCustomerDetailsVC else {
            return
        }
        tdVC.DEALER_CODE = "N1A03"
        tdVC.customerDetails = customerInfo
        tdVC.delegate = self
  
        
        self.present(tdVC, animated: true, completion: nil)
       // self.navigationController?.pushViewController(tdVC, animated: true)
    }

}


extension ViewController: TestDriveDelegate {
    func didFinishTestDrive(testDrive: TestDriveData?, error: Error?) {
        print("Success")
    }
    
    func didFailToGetTestDriveData(error: Error?) {
        print("Success")
    }
    
    
}
