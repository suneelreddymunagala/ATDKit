//
//  TDVariantDetailsViewController.swift
//  TDKit
//
//  Created by Suneel on 21/07/22.
//

import UIKit
import DropDown

class TDVariantDetailsVC: UIViewController {
    
    
    @IBOutlet weak var middleView: UIView!
    
    @IBOutlet weak var petrolLabel: UILabel!
    @IBOutlet weak var dieselLabel: UILabel!
    @IBOutlet weak var manualLabel: UILabel!
    @IBOutlet weak var automaticLabel: UILabel!
    @IBOutlet weak var variantLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var petrolButton: UIButton!
    @IBOutlet weak var dieselButton: UIButton!
    @IBOutlet weak var manualButton: UIButton!
    @IBOutlet weak var automaticButton: UIButton!
    
    @IBOutlet weak var carImageView: UIImageView!
    
    var TD_CAR_DETAILS: TDCarData?=nil
    var CAR_TD_PATH: String? = nil
    
    
    private var fileManager = FileManager()
    
    fileprivate var petrolButtonValue: Bool = false {
        didSet {
            let image = (petrolButtonValue == false) ? TDImage.getunSelectImage() : TDImage.getSelectedImage()
            self.petrolButton.setImage(image, for: .normal)
        }
    }
    
    
    fileprivate var dieselButtonValue: Bool = false {
        didSet {
            let image = (dieselButtonValue == false) ? TDImage.getunSelectImage() : TDImage.getSelectedImage()
            self.dieselButton.setImage(image, for: .normal)
        }
    }
    
    fileprivate var manualButtonValue: Bool = false {
        didSet {
            let image = (manualButtonValue == false) ? TDImage.getunSelectImage() : TDImage.getSelectedImage()
            self.manualButton.setImage(image, for: .normal)
        }
    }
    
    fileprivate var automaticButtonValue: Bool = false {
        didSet {
            let image = (automaticButtonValue == false) ? TDImage.getunSelectImage() : TDImage.getSelectedImage()
            self.automaticButton.setImage(image, for: .normal)
        }
    }
    
    var languageDetail: [LanguageDetail] = []
    
    var petrolAutomaticData : [TransmissionDetails] = []
    var petrolManualData: [TransmissionDetails] = []
    var dieselAutomaticData: [TransmissionDetails] = []
    var dieselManualData: [TransmissionDetails] = []
    
    let languageDropDown = DropDown()
    let variantDropDown = DropDown()
    
    fileprivate var selectedLanguage: LanguageDetail? = nil
    fileprivate var selectedTransmissionData: TransmissionDetails? = nil
    fileprivate var dropdownData = [TransmissionDetails]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
        self.getVariantData()
    }
    
//MARK: UIButton Actions
    @IBAction func petrolBtnAction(_ sender: UIButton) {
        
        petrolButtonValue = !petrolButtonValue
        self.dieselButtonValue = !petrolButtonValue
        
        self.setSelection(isComingFrom: true, iscomingFrom: self.automaticButtonValue, automaticData: self.petrolAutomaticData, manualData: self.petrolManualData)
    }
    
    @IBAction func dieselBtnAction(_ sender: UIButton) {
        
        dieselButtonValue = !dieselButtonValue
        self.petrolButtonValue = !dieselButtonValue
        
        self.setSelection(isComingFrom: false, iscomingFrom: self.automaticButtonValue, automaticData: self.dieselAutomaticData, manualData: self.dieselManualData)
    }
    
    @IBAction func manualBtnAction(_ sender: UIButton) {
        manualButtonValue = !manualButtonValue
        self.automaticButtonValue = !manualButtonValue
        
        if self.petrolButtonValue {
            self.setSelection(isComingFrom: self.petrolButtonValue, iscomingFrom: false, automaticData: self.petrolAutomaticData, manualData: self.petrolManualData)
        } else {
            self.setSelection(isComingFrom: self.petrolButtonValue, iscomingFrom: false, automaticData: self.dieselAutomaticData, manualData: self.dieselManualData)
        }
    }
    
    @IBAction func automaticBtnAction(_ sender: UIButton) {
        automaticButtonValue = !automaticButtonValue
        self.manualButtonValue = !automaticButtonValue
        
        if self.petrolButtonValue {
            self.setSelection(isComingFrom: self.petrolButtonValue, iscomingFrom: true, automaticData: self.petrolAutomaticData, manualData: self.petrolManualData)
        } else {
            self.setSelection(isComingFrom: self.petrolButtonValue, iscomingFrom: true, automaticData: self.dieselAutomaticData, manualData: self.dieselManualData)
        }
    }
    
    @IBAction func variantBtnAction(_ sender: UIButton) {
        if petrolButtonValue && manualButtonValue {
            dropdownData = self.petrolManualData
            setUpVariantDropDown()
            self.variantDropDown.show()
        } else if petrolButtonValue && automaticButtonValue {
            dropdownData = self.petrolAutomaticData
            setUpVariantDropDown()
            self.variantDropDown.show()
        } else if dieselButtonValue && manualButtonValue{
            dropdownData = dieselManualData
            setUpVariantDropDown()
            self.variantDropDown.show()
        } else if dieselButtonValue && automaticButtonValue {
            dropdownData = dieselAutomaticData
            setUpVariantDropDown()
            self.variantDropDown.show()
        } else {
            variantDropDown.hide()
        }
    }
    
    @IBAction func languageBtnAction(_ sender: UIButton) {
        self.languageDropDown.show()
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        
        guard let carTDPath = self.CAR_TD_PATH, let _ = self.TD_CAR_DETAILS else {
            self.navigationController?.popViewController(animated: true)
            return }
        
        guard let selectedLan = self.selectedLanguage, let selectedTData = self.selectedTransmissionData else {
            self.showAlert(message: "select language details and variant details", viewController: self)
            return
        }

        let fuelType = petrolButtonValue ? "Petrol" : "Diesel"
        let tranmissionType = self.automaticButtonValue ? "Automatic" : "Manual"
        
        let selectedLanguage = selectedLan.language
        let transmissionTypeID = selectedTData.variantID
        
        let variantPath = selectedLanguage + "_" + fuelType + "_" + tranmissionType + "_" + String(transmissionTypeID)
        
        print("variantPath--->",variantPath)
        
        let variantPathWithJson = carTDPath+"/"+variantPath+".json"
        if (FileManager.default.fileExists(atPath: variantPathWithJson)) {
           print("car detailsa are avaialble show trigger screen")
            guard let triggerVC = TDVCManager.openTriggerVC() else { return  }
            triggerVC.TD_CAR_FILEPATH = variantPathWithJson
            triggerVC.CAR_ASSET_PATH = carTDPath
//            triggerVC.selectedCar = SelectedCarData(carName: carData.carName, carId: carData.carID, assestVersion: 1)
            self.navigationController?.pushViewController(triggerVC, animated: true)
        }
        
        
    }

private func getVariantData() {
    
    guard let carData = self.TD_CAR_DETAILS else { return  }
    guard NetworkReachability.isConnectedToNetwork() else {
        return
    }
        let variantAndLanguageUrl = TDAPI.TD_VARINAT_AND_LANGUAGE_DETAILS + String(carData.carID)
        
        print("variantAndLanguageUrl--->",variantAndLanguageUrl)
   //     SharedClass.sharedInstance.showLoader(message: "Loading...")
        TDAPIManager.getVariantAndLanguagedetails(url: variantAndLanguageUrl, postBody: nil) { sucess, resposneStr, uwData in
            DispatchQueue.main.async {
                if let vAndLData = uwData, sucess {
                    self.languageDetail = vAndLData.languageDetails
                    self.petrolAutomaticData = vAndLData.variantDetails.petrol.automatic
                    self.petrolManualData = vAndLData.variantDetails.petrol.manual
                    self.dieselAutomaticData = vAndLData.variantDetails.diesel.automatic
                    self.dieselManualData = vAndLData.variantDetails.diesel.manual
                    self.setUpAllVariantDetails()
                    self.setUpVariantDropDown()
                    self.setUpLanguageDropDown()
                }
            }
        }
    }
    
    
   fileprivate func setUpVariantDropDown() {
        variantDropDown.width = self.variantLabel.frame.width
        self.variantDropDown.anchorView = self.variantLabel
        self.variantDropDown.direction = .bottom
        self.variantDropDown.dataSource = self.getVariantNames(dropdownData)
        
        if dropdownData.count > 0 {
            self.selectedTransmissionData = self.dropdownData[0]
        }
       
        variantDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let variantName = self.dropdownData[index].variantName
            self.variantLabel.text = ""
            if variantName == item {
                self.selectedTransmissionData = self.dropdownData[index]
                self.variantLabel.text = item
                variantDropDown.show()
            }
        }
    }
    
    fileprivate func setUpLanguageDropDown() {
        self.languageDropDown.dataSource = self.getLanguage(languageDetail)
        languageDropDown.width = self.languageLabel.frame.width
        self.languageDropDown.anchorView = self.languageLabel
        self.languageDropDown.direction = .bottom
        
        if (languageDetail.count > 0) {
            self.selectedLanguage = self.languageDetail[0]
        }
        languageDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let lang = self.languageDetail[index].language
            self.languageLabel.text = ""
            if lang == item {
                self.selectedLanguage = self.languageDetail[index]
                self.languageLabel.text = item
            }
        }
    }
    
    func getVariantNames(_ variantData: [TransmissionDetails]) -> [String] {
        var variantNames: [String] = []
        for variant in dropdownData {
            variantNames.append(variant.variantName)
        }
        return variantNames
    }
    
    func getLanguage(_ languageData: [LanguageDetail]) -> [String]{
        var languages: [String] = []
        for language in languageDetail {
            languages.append(language.language)
        }
        return languages
    }
}

//MARK: UI
extension TDVariantDetailsVC {
   fileprivate func setUpUI() {
       
       self.view.backgroundColor = .white
        middleView.layer.borderWidth = 1.0
        middleView.layer.borderColor = UIColor.black.cgColor
        middleView.layer.masksToBounds = true
        
        self.petrolButtonValue = false
        self.dieselButtonValue = false
        self.automaticButtonValue = false
        self.manualButtonValue = false
        self.petrolButton.isEnabled = false
        self.dieselButton.isEnabled = false
        self.manualButton.isEnabled = false
        self.automaticButton.isEnabled = false
       
       
       if let carData = self.TD_CAR_DETAILS {
           let carImageUrl = carData.carThumbnailImageFile
           let carfileNameStr = String(carImageUrl.split(separator: "/").last ?? "")
           let documentUrl = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).first!
           let imagePath = documentUrl.appendingPathComponent(carfileNameStr).path
           self.carImageView.image = UIImage(contentsOfFile: imagePath)
           self.carImageView.contentMode = .scaleAspectFit
       }
    }
    
    fileprivate func setUpAllVariantDetails() {
        if dieselAutomaticData.count > 0 || self.dieselManualData.count > 0 {
            self.dieselButton.isEnabled = true
            if dieselAutomaticData.count > 0 {
            //    dropdownData = dieselAutomaticData
                self.setSelection(isComingFrom: false, iscomingFrom: true, automaticData: self.dieselAutomaticData, manualData: self.dieselManualData)
            } else {
             //   dropdownData = dieselManualData
                self.setSelection(isComingFrom: false, iscomingFrom: false, automaticData: self.dieselAutomaticData, manualData: self.dieselManualData)
            }
        }
        if petrolAutomaticData.count > 0 || self.petrolManualData.count > 0 {
            self.petrolButton.isEnabled = true
            if petrolAutomaticData.count > 0 {
              //  dropdownData = petrolAutomaticData
                self.setSelection(isComingFrom: true, iscomingFrom: true, automaticData: self.petrolAutomaticData, manualData: self.petrolManualData)
            } else {
               // dropdownData = petrolManualData
                self.setSelection(isComingFrom: true, iscomingFrom: false, automaticData: self.petrolAutomaticData, manualData: self.petrolManualData)
            }
            
        }
    }
    
    fileprivate func setSelection(isComingFrom petrol: Bool, iscomingFrom automatic: Bool, automaticData: [TransmissionDetails], manualData: [TransmissionDetails]) {
        
        self.automaticButton.isEnabled = false
        self.manualButton.isEnabled = false
        
        self.petrolButtonValue = petrol
        self.dieselButtonValue = !petrol
        self.automaticButton.isEnabled = (automaticData.count > 0)
        self.manualButton.isEnabled = (manualData.count > 0)
        self.automaticButtonValue = automatic
        self.manualButtonValue = !automatic
    }
    
}
