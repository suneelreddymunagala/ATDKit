//
//  TDCustomerDetailsVC.swift
//  TDKit
//
//  Created by Suneel on 20/07/22.
//

import UIKit

public class TDCustomerDetailsVC: UIViewController {
    
    //Customer details
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var testDriveDateTextField: UITextField!
    @IBOutlet weak var testdriveTimeTxtField: UITextField!
    @IBOutlet weak var carModelTextField: UITextField!
    
    public var DEALER_CODE: String? = nil
    
    fileprivate var fileManager = FileManager()
    
    fileprivate var SELECTED_TD_CAR_DATA: TDCarData? {
        didSet {
            guard let carData = SELECTED_TD_CAR_DATA else { return }
            self.carModelTextField.text = carData.carName
        }
    }
    
    public var customerDetails: TDCustomerInfo? {
        didSet {
            guard let carModel = customerDetails?.carModel else { return }
                self.getAllCarDetailsData(gdmsCarModel: carModel)
        }
    }
    
    static let myNotification = Notification.Name("startGame")
    
    public var delegate: TestDriveDelegate? = nil

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: TDCustomerDetailsVC.myNotification, object: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    
    
    //MARK: UI Button Actions
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.didFinishTestDrive(testDrive: nil, error: nil)
    }
    
    @IBAction func submitBtnAction(_ sender: UIButton) {
        if let tdCarData = self.SELECTED_TD_CAR_DATA {
            self.checkTDAssestsAreAvailble(carID: tdCarData.carID)
        } else {
            let alertVC = UIAlertController(title: "", message: "This Car model not available for this dealer.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: .default) { (okAction) in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    @objc func onNotification(notification:Notification) {
        self.delegate?.didFinishTestDrive(testDrive: nil, error: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    private func setDefaultOrientationToLeft() {
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    //MARK: Private methods
    private func openLinkInExternalBrowser() {
        let gdmsAppURLStr = "hyundaiIndiaGDMSApp://"
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        
        if let gdmsAppURLStrVal = gdmsAppURLStr.addingPercentEncoding(withAllowedCharacters: characterSet) {
            if let gdmsAppURL = URL(string: gdmsAppURLStrVal) {
                
                guard UIApplication.shared.canOpenURL(gdmsAppURL) else {
                    self.showAlert(message: "GDMS APP Not available", viewController: self)
                    return
                }
                UIApplication.shared.open(gdmsAppURL, options: [:], completionHandler: nil)
            }
        } else {
            self.showAlert(message: "Unable to communicate to GDMS App", viewController: self)
        }
    }
    
    
    
    fileprivate func getAllCarDetailsData(gdmsCarModel: String) {
        guard NetworkReachability.isConnectedToNetwork() else { return}
        var allCarsurlString = TDAPI.ALL_CARS
        
        
        guard let dealerCode = self.DEALER_CODE else {
            self.showAlert(message: "Dealer code is empty.", viewController: self)
            return
        }
        
        let parameters = ["dealercode": dealerCode]
        
        guard let urlwithQueryItems = allCarsurlString.queryString(params: parameters) else {
            return
        }
        
        allCarsurlString = urlwithQueryItems
        allCarsurlString = allCarsurlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        print("getAllCarDetailsData--->",allCarsurlString)
        // SharedClass.sharedInstance.showLoader(message: "Loading...")
        TDCarApiManager.getAllCarsData(url: allCarsurlString, postBody: nil) { (success, responseStr, allCarsData) in
            DispatchQueue.main.async {
              
                guard success else { return }
                print("Car details --->")
                if let allCarDetailsData = allCarsData  {
                    print("allCarDetailsData -->", allCarDetailsData)
                    
                    let filteredCarList = allCarDetailsData.filter { carData in
                        return (carData.gdmsCarName?.lowercased() ?? "" == gdmsCarModel.lowercased())
                    }
                    if (filteredCarList.count > 0) {
                        print("filteredCarList --->", filteredCarList[0])
                        self.SELECTED_TD_CAR_DATA = filteredCarList[0]
                        self.setUpGDMSData()
                    }
                }
            }
        }
    }
    
    
    private func setUpGDMSData() {
        if let customerData = customerDetails {
//            let tdID = gdmsAppURL?.valueOf("td_id") ?? ""
//            let dealerNumber = gdmsAppURL?.valueOf("dlrno") ?? ""
//            let customerID = gdmsAppURL?.valueOf("customer_id") ?? ""
//
//            TDUserSession.GDMS_APP_TD_DATA = GDMSAppData(tdId: tdID, customerId: customerID, dealerNumber: dealerNumber)
//
//            var customerName = gdmsAppURL?.valueOf("customer_name")
//            customerName = customerName?.replacingOccurrences(of: "%20", with: " ")
//            let email = gdmsAppURL?.valueOf("customer_email")
//            let phoneNumber = gdmsAppURL?.valueOf("customer_phone")
//
//            var address = gdmsAppURL?.valueOf("address")
//            address = address?.replacingOccurrences(of: "%2520", with: " ")
//            address = address?.replacingOccurrences(of: "%20", with: " ")
//
//            var tdDate = gdmsAppURL?.valueOf("test_drive_date")
//            tdDate = tdDate?.replacingOccurrences(of: "%20", with: " ")
//
//            var tdTime = gdmsAppURL?.valueOf("test_drive_time")
//            tdTime = tdTime?.replacingOccurrences(of: "%20", with: " ")
            
            let tdID = customerData.tdId
            let dealerNumber = customerData.dlrno
            let customerID = customerData.customerId
            
            TDUserSession.GDMS_APP_TD_DATA = GDMSAppData(tdId: String(tdID), customerId: String(customerID), dealerNumber: dealerNumber)
            
            var customerName = customerData.customerName
                        customerName = customerName.replacingOccurrences(of: "%20", with: " ")
            let email = customerData.customerEmail
            let phoneNumber = customerData.customerPhone
            
            var address = customerData.address
                        address = address.replacingOccurrences(of: "%2520", with: " ")
                        address = address.replacingOccurrences(of: "%20", with: " ")
            
            var tdDate = customerData.testDriveDate
                        tdDate = tdDate.replacingOccurrences(of: "%20", with: " ")
            
            var tdTime = customerData.testDriveTime
                        tdTime = tdTime.replacingOccurrences(of: "%20", with: " ")
            
            self.nameTxtField.text = customerName
            self.emailTextField.text = email
            self.phoneNumberTextField.text = phoneNumber
            self.addressTextField.text = address
            self.testDriveDateTextField.text = tdDate
            self.testdriveTimeTxtField.text = tdTime
        }
    }
    
    private func createFilePath() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var filePath = paths.first!
        filePath.append("/HyundaiSSC")  // name of the folder for the downloaded zip file
        print("TD File Path for downloaded cars ---------------> \(filePath)")
        if(!FileManager.default.fileExists(atPath: filePath)) {
            try! FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: false, attributes: nil)
            UserDefaults.standard.set(filePath, forKey: "file_Path_For_Folder_Creation")
        }
    }
    
    private func checkTDAssestsAreAvailble(carID: Int) {
    
        guard let sscFolderList = self.fileManager.getAllFolderNamesFromSSCApp(), (sscFolderList.count > 0) else {
            self.showAlert(message: "SSC Main folder is dissming", viewController: self)
            self.createFilePath()
            return
        }
        
        let filteredFolderList = sscFolderList.filter { folderName in
            return ((Int(folderName) ?? 0) == carID) ? true : false
        }
        
        
        guard (filteredFolderList.count > 0) else {
            self.showAlert(message: assetsDataError, viewController: self)
            return
        }
        let tdCarFolderName = filteredFolderList[0]
      //  print("selectedProductFolderName--->",tdCarFolderName)
        let tdPath = "/HyundaiSSC/\(tdCarFolderName)/TDData"
        var testDriveFilePath = self.fileManager.getTDDocumnetaryPath()
        testDriveFilePath.append(contentsOf: tdPath)
        
        print("testDriveFilePath===>",testDriveFilePath)
    
        guard FileManager.default.fileExists(atPath: testDriveFilePath) else {
            self.showAlert(message: assetsDataError, viewController: self)
            return
        }
        let carTDPath = self.fetchCarTDPath(testDrivePath: testDriveFilePath)
        
            let downloadedData = FileManager.default.fileExists(atPath: carTDPath)
        
        if downloadedData {
            self.navigateToVariantVC(carTdPath: carTDPath)
        } else {
            self.showAlert(message: restoreAlertTitle, viewController: self)
        }
    }
    
    private func navigateToVariantVC(carTdPath: String) {
        guard let variantVC = TDVCManager.openVariantDetailsVC() else {
            return
        }
        variantVC.TD_CAR_DETAILS = self.SELECTED_TD_CAR_DATA
        variantVC.CAR_TD_PATH = carTdPath
        self.navigationController?.pushViewController(variantVC, animated: true)
    }
    
    private func fetchCarTDPath(testDrivePath: String) -> String {
        let files = self.fileManager.enumerator(atPath: testDrivePath)
        
        var carTDPath = ""
        while let file = files?.nextObject() {
            let filestr = file as? String ?? ""
            if filestr.count > 0 {
                if !(filestr.contains("DS_Store")) {
                    carTDPath = testDrivePath + "/" + filestr
                    break
                }
            }
        }
        return carTDPath
    }
    
}

//MARK: UI
extension TDCustomerDetailsVC {
    internal func setUpUI() {
        nameTxtField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        phoneNumberTextField.isUserInteractionEnabled = false
        addressTextField.isUserInteractionEnabled = false
        testDriveDateTextField.isUserInteractionEnabled = false
        testdriveTimeTxtField.isUserInteractionEnabled = false
        carModelTextField.isUserInteractionEnabled = false
        
        self.setDefaultOrientationToLeft()
    }
    
    
    
}
