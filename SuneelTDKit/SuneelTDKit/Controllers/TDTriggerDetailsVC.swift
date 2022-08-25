//
//  TDTriggerDetailsVC.swift
//  TDKit
//
//  Created by Suneel on 21/07/22.
//

import UIKit
import AVFoundation
import CoreBluetooth
import LTSupportAutomotive

struct PlayedTrigger {
    var trigger_type: String
    var feature: String
}

public class TDTriggerDetailsVC: UIViewController {
    
    @IBOutlet weak var triggerCV: UICollectionView!
    
    @IBOutlet weak var pauseAndPlayBtn: UIButton!
    @IBOutlet weak var muteAndUnMuteBtn: UIButton!
    @IBOutlet weak var connectBtn: UIButton!
    
    @IBOutlet weak var rpmTextLabel: UILabel!
    @IBOutlet weak var speedTextLabel: UILabel!
    @IBOutlet weak var distanceTextLabel: UILabel!
    
    @IBOutlet weak var finishBtn: UIButton!
    
    @IBOutlet weak var deviceTV: UITableView!
    @IBOutlet weak var connectBluetoothPopupView: UIView!
    @IBOutlet weak var deviceDetailsCancelBtn: UIButton!
    
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var bTErrorPopUPView: UIView!
    @IBOutlet weak var btErrorLabel: UILabel!
    @IBOutlet weak var btErrorOkBtn: UIButton!
    
    // Properties
    fileprivate var centralManager: CBCentralManager! //iOS Device instance
    fileprivate var vGatePeripheral: CBPeripheral! //Bluetooth device instance
    
    fileprivate var ALL_TRIGGERS = [TriggerDetails]()
    
    fileprivate var ALL_PERIPHERALS: [CBPeripheral] = [] {
        didSet {
            if (self.ALL_PERIPHERALS.count > 0) {
                self.deviceTV.reloadData()
            }
        }
    } //to load peripherals
    
    fileprivate var MAIN_TRIGGERS: [TriggerDetails] = [] {
        didSet {
            if (self.MAIN_TRIGGERS.count > 0) {
                self.triggerCV.reloadData()
            }
        }
    } // main triggers are without end audio trigger
    
    
    var TD_CAR_FILEPATH: String? = nil
    var CAR_ASSET_PATH: String? = nil
    
    fileprivate var RPM_QUEUE_ARRAY: [Int] = []
    fileprivate var SPEED_QUEUE_ARRAY: [Int] = []
    fileprivate let QUEUE_SIZE = 20
    
    fileprivate var transporter: LTBTLESerialTransporter = LTBTLESerialTransporter()
    fileprivate var obd2Adapter: LTOBD2Adapter!
    fileprivate var pids: [LTOBD2PID]? = [LTOBD2PID]()
    
    fileprivate var RPM_VALUE: Int = 0 {
        didSet {
            self.RPM_QUEUE_ARRAY.append(self.RPM_VALUE)
            self.rpmTextLabel.text = "RPM\n" + String(self.RPM_VALUE)
        }
    }
    
    fileprivate var SPEED_VALUE: Int = 0 {
        didSet {
            self.SPEED_QUEUE_ARRAY.append(self.SPEED_VALUE)
            self.speedTextLabel.text = "SPEED\n" + String(SPEED_VALUE)
        }
    }
    
    fileprivate var DISTANCE_TRAVELLED: Int = 00 {
        didSet {
            self.distanceTextLabel.text = "DISTANCE \n" + String(DISTANCE_TRAVELLED)
        }
    }
    
    //BLUETOOTH VARIABLES
   // var bleManager: BLEManager = BLEManager()
    
 //   var centralManager: CBCentralManager? = nil
    var discoveredPeripheral: CBPeripheral!
    fileprivate var SCANNING_MODE:Bool = false
    
    //MARK: Timers
    fileprivate var CONNECTION_TO_PERIPHERAL_TIMER: Timer? = nil
    fileprivate var RPM_AND_SPEED_TIMER: Timer? = nil
    fileprivate var BT_SCANNING_TIMER: Timer? = nil
    fileprivate var PLAY_MARKETING_TRIGGER_TIMER:Timer = Timer()
    
    
    func removeAllTimers() {
        self.CONNECTION_TO_PERIPHERAL_TIMER?.invalidate()
        self.CONNECTION_TO_PERIPHERAL_TIMER = nil
        
        self.RPM_AND_SPEED_TIMER?.invalidate()
        self.RPM_AND_SPEED_TIMER = nil
        
        self.BT_SCANNING_TIMER?.invalidate()
        self.BT_SCANNING_TIMER = nil
        
        self.PLAY_MARKETING_TRIGGER_TIMER.invalidate()
    }
    
    
    var audioPlayer: AVAudioPlayer!
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    let noSensorsAlertVC = UIAlertController(title: "", message: "Please check device connection/Turn on the car and Connect", preferredStyle: .alert)
    
    fileprivate var isAudioPaused = false
    
    fileprivate var isOBDTriggerisCalled = false
    fileprivate var isMarketingFeaturesTriggered = false
    
    fileprivate var IS_USER_CLICKED_TRIGGER = false // when user click on trigger save it for logs.
    
    fileprivate var PLAYED_TRIGGERS = [PlayedTrigger]()
    fileprivate var SELECTED_PLAYING_TRIGGER_INDEX: Int? = nil
    
    fileprivate var IS_ENGINE_PICKUP_TRIGGER_PLAYED = false
    fileprivate var IS_SOFT_BRAKE_TRIGGER_PLAYED = false
    fileprivate var IS_SMOOTH_ACCELERATION_TRIGGER_PLAYED = false
    fileprivate var IS_CRUISE_CONTROL_TRIGGER_PLAYED = false
    fileprivate var IS_EGINE_IDLING_TRIGGER_PLAYED = false
    fileprivate var resetSpeedAndRPMValues = false
    
    
    let fileManager = FileManager()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.PLAYED_TRIGGERS = []
        self.changeConnectBtnState(state: 0)
        self.hideBluetoothErrorPopUp()
        hideCarNoDataSensorAlertVC()
        hideLoading()
        self.fileManager.delegate = self
        self.hideDeviceDetailsPopUP()
        self.setUpUI()
        self.setUpCarDetails()
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(streamEventchanged(notification:)), name: NSNotification.Name("StreamEventchanged"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(pidDataDidUpdate(notification:)), name: NSNotification.Name.faobd2PIDDataUpdated, object: nil)
        
        
        self.SPEED_QUEUE_ARRAY = []
        self.RPM_QUEUE_ARRAY = []
        self.RPM_AND_SPEED_TIMER = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.addRPMAndSpeedValueToArray), userInfo: nil, repeats: true)
        
        self.SCANNING_MODE = true
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
//        self.bleManager = BLEManager.sharedInstance() as! BLEManager
//        self.bleManager.bledelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.screenLockedUpdate(notification:)), name: Notification.Name("screen_Locked"), object: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeAllTimers()
    }
    
    
    //MARK: Button Actions
    @IBAction func finishBtnAction(_ sender: UIButton) {
 
        if let navigationVCS = self.navigationController?.viewControllers {
            for vc in navigationVCS {
                if vc is TDCustomerDetailsVC {
                    
                    self.navigationController?.popToViewController(vc, animated: false)
                    NotificationCenter.default.post(name: TDCustomerDetailsVC.myNotification, object: nil)
                    break
                }
            }
        }
    }
   
    
    @IBAction func btErrorOkBtnAction(_ sender: UIButton) {
        self.SCANNING_MODE = true
        self.startScanningForPheripherals()
    }
    
    @IBAction func cancelDeviceDetailsBtnAction(_ sender: UIButton) {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        
      //  self.bleManager.bledelegate = self
        self.ALL_PERIPHERALS = []
        
        self.hideBluetoothErrorPopUp()
        self.stopScanningForPeripherals()
//        if((self.bleManager.discoveredPeripheral) != nil) {
//            self.bleManager.centralManager.cancelPeripheralConnection(self.bleManager.discoveredPeripheral)
//        }
        
        if (self.vGatePeripheral != nil) {
            self.centralManager.cancelPeripheralConnection(self.vGatePeripheral)
        }
        
        self.changeConnectBtnState(state: 0)
        self.connectBluetoothPopupView.isHidden = true
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func pauseAndPlayBtnAction(_ sender: UIButton) {
        
        if (self.pauseAndPlayBtn.tag == 0) {
            self.pauseAndPlayBtn.tag = 1
            if isAudioPaused {
                self.audioPlayer?.play()
                isAudioPaused = false
            } else {
                self.synthesizer.stopSpeaking(at: .immediate)
                
                if (MAIN_TRIGGERS.count > 0) {
                    let triggerdetails = MAIN_TRIGGERS[0]
                    if !(triggerdetails.isAudioPlayed ?? false) {
                        self.playMarketingTriggersAutomatically(trigger: triggerdetails)
                    }
                }
            }
        } else if (self.pauseAndPlayBtn.tag == 1) {
            self.pauseAndPlayBtn.tag = 0
            let isAudioPlaying = self.audioPlayer?.isPlaying ?? false
            self.isAudioPaused = isAudioPlaying ? true : false
            isAudioPlaying ? self.audioPlayer?.pause() : self.audioPlayer?.stop()
        }
    }
    
    @IBAction func muteAndUnMuteBtnAction(_ sender: UIButton) {
        
        if self.pauseAndPlayBtn.tag == 1 {
            if let volume = self.audioPlayer?.volume {
                if volume <= 0 {
                    sender.isSelected = false
                    
                    self.muteAndUnMuteBtn.setTitle("sound", for: .normal)
                    //  self.muteImgView.image = UIImage(named: "volume_on")
                    self.audioPlayer?.setVolume(1.0, fadeDuration: 1.0)
                } else {
                    sender.isSelected = true
                    self.muteAndUnMuteBtn.setTitle("no sound", for: .normal)
                    // self.audioPlayer?.setVolume(0.0, fadeDuration: 1.0)
                }
            }
        }
    }
    
    @IBAction func connectBtnAction(_ sender: UIButton) {
        if (sender.titleLabel?.text == "Connected") {
            let alert = UIAlertController(title: "", message: "Are you sure you want to disconnect!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.changeConnectBtnState(state: 0)
                self.transporter.disconnect()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (sender.titleLabel?.text == "Connect") {
           // self.bleManager.bledelegate = self
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
            
            self.SCANNING_MODE = true
            self.startScanningForPheripherals()
            sender.sizeToFit()
        }
        sender.sizeToFit()
    }
    fileprivate func playMarketingTriggersAutomatically(trigger: TriggerDetails) {
        isOBDTriggerisCalled = false
        isMarketingFeaturesTriggered = false
        if trigger.triggerName == WELCOME_MESSAGE_TRIGGER {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(playFromSelectedIndex(timer:)), userInfo: ["index": 0], repeats: false)
        } else if !trigger.isMarketingTrigger {
            SPEED_QUEUE_ARRAY = []
            RPM_QUEUE_ARRAY = []
            
            let triggerType = IS_USER_CLICKED_TRIGGER ? "click" : "obd"
            
            let playedTrigger = PlayedTrigger(trigger_type: triggerType, feature: trigger.feature)
            self.PLAYED_TRIGGERS.append(playedTrigger)
            let marketingArrayIndexes = getAllindexesOfMarketingTriggers()
            
            if let triggerIndex = self.getTheNotPlayedMarketingTriggerIndex(indexList: marketingArrayIndexes) {
                self.PLAY_MARKETING_TRIGGER_TIMER = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(playFromSelectedIndex(timer:)), userInfo: ["index": triggerIndex], repeats: false)
            }
        } else {
            SPEED_QUEUE_ARRAY = []
            RPM_QUEUE_ARRAY = []
            
            let triggerType = IS_USER_CLICKED_TRIGGER ? "click" : "time_based"
            
            let playedTrigger = PlayedTrigger(trigger_type: triggerType, feature: trigger.feature)
            self.PLAYED_TRIGGERS.append(playedTrigger)
            let marketingArrayIndexes = getAllindexesOfMarketingTriggers()
            
            if let triggerIndex = self.getTheNotPlayedMarketingTriggerIndex(indexList: marketingArrayIndexes) {
                self.PLAY_MARKETING_TRIGGER_TIMER = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(playFromSelectedIndex(timer:)), userInfo: ["index": triggerIndex], repeats: false)
            }
        }
    }
    
    @objc func playFromSelectedIndex(timer: Timer) {
        
        if isOBDTriggerisCalled == false {
            if  let userInfo = timer.userInfo as? [String: Int],
                let triggerIndex = userInfo["index"] {
                let triggerData = self.MAIN_TRIGGERS[triggerIndex]
                isMarketingFeaturesTriggered = true
                if let carTdPath = self.CAR_ASSET_PATH {
                    let audioFilesArray = triggerData.audioFile
                    if audioFilesArray.count > 0 {
                        let feature_Audio_FilePath = "\(carTdPath)/\(audioFilesArray[0])"
                        let soundFileURL: URL = URL(fileURLWithPath: feature_Audio_FilePath)
                        
                        if (self.audioPlayer != nil) {
                            if let volumeState: Float = self.audioPlayer?.volume {
                                self.audioPlayer?.stop()
                                self.audioPlayer = try! AVAudioPlayer(contentsOf: soundFileURL)
                                self.audioPlayer?.volume = volumeState
                            }
                        } else {
                            self.audioPlayer = AVAudioPlayer()
                            self.audioPlayer = try! AVAudioPlayer.init(contentsOf: soundFileURL)
                        }
                    }
                }
                
                self.audioPlayer?.delegate = self
                self.audioPlayer?.prepareToPlay()
                
                if let _: Float = self.audioPlayer?.volume {
                    let audioValue = muteAndUnMuteBtn.isSelected ? 0.0 : 1.0
                    self.audioPlayer?.setVolume(Float(audioValue), fadeDuration: 1.0)
                }
                
                self.pauseAndPlayBtn.tag = 1
              
                self.audioPlayer?.stop()
                self.audioPlayer?.play()
                // setSessionPlayerOn()
                self.IS_USER_CLICKED_TRIGGER = false
                
                let indexPath = IndexPath(item: triggerIndex, section: 0)
                self.triggerSelectedUpdateUIOnCellClick(indexPath: indexPath)
            }
        }
    }
    
    func triggerSelectedUpdateUIOnCellClick(indexPath:IndexPath) {
        self.SELECTED_PLAYING_TRIGGER_INDEX = indexPath.item
        self.triggerCV.reloadData()
        self.scrollToMiddle(selectedRow: indexPath.row)
    }
    
    
    
    fileprivate func getTheNotPlayedMarketingTriggerIndex(indexList: [Int]) -> Int? {
        if indexList.count > 0 {
            for index in indexList {
                let trigger = self.MAIN_TRIGGERS[index]
                let isAudioPlayed = trigger.isAudioPlayed ?? false
                if isAudioPlayed {
                    continue
                } else {
                    return index
                }
            }
        }
        return nil
    }
    
    fileprivate func getAllindexesOfMarketingTriggers() -> [Int] {
        var marketingTriggersIndexArray = [Int]()
        
        for (triggerIndex, trigger) in self.MAIN_TRIGGERS.enumerated() {
            let isMarketingTrigger = trigger.isMarketingTrigger
            if isMarketingTrigger {
                marketingTriggersIndexArray.append(triggerIndex)
            }
        }
        return marketingTriggersIndexArray
    }
    
    
    @objc func screenLockedUpdate(notification: Notification){
        print("Bluetooth disconnected")
        if (self.connectBtn.titleLabel?.text == "Connected") {
            //            if(self.startBtn.titleLabel?.text == "Stop") {
            //                self.audioPlayer = nil
            //            }
            self.audioPlayer = nil
            self.audioPlayer = AVAudioPlayer()
            //self.startBtn.setTitle("Start", for: .normal)
            //  self.startImgView.image = UIImage(named: "play")
            self.RPM_QUEUE_ARRAY = []
            self.SPEED_QUEUE_ARRAY = []
            //  self.distanceLabel.text = " Distance: 0 0"
            transporter.disconnect()
            self.changeConnectBtnState(state: 0)
            //            self.playMarketingTriggerTimer.invalidate()
            //            self.playMarketingTriggerTimer = Timer()
            //   textLog.write("======screenLockedUpdate=====\n")
            obdConnectAlert()
        }
    }
    
    func obdConnectAlert() {
        //   textLog.write("======obdConnectAlert=====\n")
        let alertVC = UIAlertController(title: "", message: "OBD got disconnected", preferredStyle: .alert)
        let connectAction = UIAlertAction(title: "Connect", style: .default) { (action) in
            DispatchQueue.main.async {
                self.SCANNING_MODE = true
                self.startScanningForPheripherals()
            }
        }
        alertVC.addAction(connectAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func addRPMAndSpeedValueToArray() {
        
        
        print("Audio triggered----", checkIfCarStartedOrNot())
        if self.checkIfCarStartedOrNot() {
            if(self.RPM_QUEUE_ARRAY.count >= QUEUE_SIZE) {
                self.RPM_QUEUE_ARRAY.remove(at: 0)
            }
            
            if(self.SPEED_QUEUE_ARRAY.count >= QUEUE_SIZE) {
                self.SPEED_QUEUE_ARRAY.remove(at: 0)
            }
            
            if self.MAIN_TRIGGERS.count > 0 {
                let welcomeTrigger = self.MAIN_TRIGGERS[0]
                let isAudioPlayed = welcomeTrigger.isAudioPlayed ?? false
                
                if isAudioPlayed {
                    self.updateDistanceData()
                    self.checkAccelerationTrigger()
                    self.checksoftbrakeTrigger()
                    self.checkPickUpTrigger()
                    self.checkCruiseControlTypeTrigger()
                    self.checkForlowNVHTrigger()
                }
            } // If Welcome triggers played, Then play OBD Triggers
        }
    }
    
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    fileprivate func hideDeviceDetailsPopUP() {
        DispatchQueue.main.async {
            self.connectBluetoothPopupView.isHidden = true
        }
    }
    
    @objc func streamEventchanged(notification: Notification) {
        let streamEventobject:NSNumber = notification.object as! NSNumber
        let streamEvent: Stream.Event = Stream.Event(rawValue: UInt(streamEventobject.intValue))
        
        self.CONNECTION_TO_PERIPHERAL_TIMER?.invalidate()
        self.CONNECTION_TO_PERIPHERAL_TIMER = Timer()
        switch streamEvent {
        case .openCompleted:
            // textLog.write("===StreamEventchanged openCompleted===\n")
            
            changeConnectBtnState(state: 1)
        case .hasBytesAvailable:
            changeConnectBtnState(state: 1)
            // textLog.write("=====StreamEventchanged hasBytesAvailable====\n")
        case .errorOccurred:
            changeConnectBtnState(state: 0)
            //  self.view.makeToast("errorOccurred")
            //  textLog.write("=====StreamEventchanged errorOccurred=====\n")
            let alert = UIAlertController(title: "", message: "Can not connect to the host!!", preferredStyle: .alert)
            let connectAction = UIAlertAction(title: "TryAgain/Connect", style: .default, handler: { action in
                self.startScanningForPheripherals()
            })
            alert.addAction(connectAction)
            self.present(alert, animated: true)
        case .endEncountered:
            changeConnectBtnState(state: 0)
            //  textLog.write("=====StreamEventchanged endEncountered=====\n")
            //  self.view.makeToast("endEncountered")
            self.obdConnectionErrorAlert()
        default: break
        }
    }
    
//    @objc func pidDataDidUpdate(notification: Notification) {
//        self.hideCarNoDataSensorAlertVC()
//        let notif_Object = notification.object as! [String:Any]
//        print("notif_Object=====>",notif_Object)
//
//        // kFAOBD2
//        // textLog.write("=====pidDataDidUpdate notif_Object\(notif_Object)=====\n")
//        if (notif_Object["sensor"] as! String == kFAOBD2PIDFuelFlow) {
//        } else if (notif_Object["sensor"] as! String == kFAOBD2PIDVehicleSpeed) {
//            let number = notif_Object["value"]
//            self.SPEED_VALUE = number as? Int ?? 0
//        } else if (notif_Object["sensor"] as! String == kFAOBD2PIDEngineCoolantTemperature) {
//        } else if (notif_Object["sensor"] as! String == kFAOBD2PIDAirIntakeTemperature) {
//        } else if (notif_Object["sensor"] as! String == kFAOBD2PIDVehicleFuelLevel) {
//        } else if (notif_Object["sensor"] as! String == kFAOBD2PIDControlModuleVoltage) {
//            let number = notif_Object["value"]
//            // textLog.write("======kFAOBD2PIDControlModuleVoltage===== \((number as AnyObject).intValue ?? 0)")
//
//        } else if (notif_Object["sensor"] as! String == kFAOBD2PIDRPM) {
//            let number = notif_Object["value"]
//            self.RPM_VALUE = number as? Int ?? 0
//            //            rpmLabel.text = "RPM : \((number as AnyObject).intValue ?? 0)"
//            //  textLog.write("======RPM in value===== \(rpmLabel.text)")
//        } else if (notif_Object["sensor"] as! String == kFAOBD2PIDPedalPosition) {
//            _ = notif_Object["value"]
//            //            pedal_positionLabel.text = "\(number?.intValue ?? 0)"
//        } else if (notif_Object["sensor"] as! String == "NO DATA") ||  (notif_Object["sensor"] as! String == "No data") {
//            let number = notif_Object["value"]
//            // textLog.write("Sensro data value Came")
//            self.showCarNodatasensorAlertVC()
//
//            self.SPEED_VALUE = number as? Int ?? 0
//            self.RPM_VALUE = number as? Int ?? 0
//
//            //            rpmLabel.text = "RPM : \((number as AnyObject).intValue ?? 0)"
//            //            //   textLog.write("======RPM in sensor===== \(rpmLabel.text)")
//            //            speedLabel.text = "Speed :\((number as AnyObject).intValue ?? 0) km/h"
//        }
//    }
    
    func showCarNodatasensorAlertVC() {
        //    textLog.write("=====showCarNodatasensor====\n")
        self.audioPlayer?.stop()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.transporter.disconnect()
        self.obd2Adapter?.disconnect()
        
        self.ALL_PERIPHERALS = []
        self.vGatePeripheral = nil
        self.SCANNING_MODE = true
        
        self.synthesizer.stopSpeaking(at: .immediate)
        self.audioPlayer = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        //                      self.devices = NSMutableSet.init()
        //                      deviceDetails = NSMutableDictionary.init()
        //                      self.scanningMode = true
        
        self.synthesizer.stopSpeaking(at: .immediate)
        self.audioPlayer = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        
        let addAction = UIAlertAction(title: "TryAgain/Connect", style: .default) { (okAction) in
            DispatchQueue.main.async {
                self.startScanningForPheripherals()
            }
        }
        noSensorsAlertVC.addAction(addAction)
        self.present(noSensorsAlertVC, animated: true, completion: nil)
    }
    fileprivate func hideCarNoDataSensorAlertVC() {
        noSensorsAlertVC.dismiss(animated: true, completion: nil)
    }
    
    func showBluetoothErrorPopUp() {
        
        self.bTErrorPopUPView.isHidden = false
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.ALL_PERIPHERALS = []
        self.SCANNING_MODE = true
        
        self.synthesizer.stopSpeaking(at: .immediate)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.RPM_AND_SPEED_TIMER?.invalidate()
        self.RPM_AND_SPEED_TIMER = Timer()
        self.RPM_AND_SPEED_TIMER = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(addRPMAndSpeedValueToArray), userInfo: nil, repeats: true)
        self.audioPlayer?.stop()
        self.PLAY_MARKETING_TRIGGER_TIMER.invalidate()
        self.PLAY_MARKETING_TRIGGER_TIMER = Timer()
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(self.bTErrorPopUPView)
        }
        
    }
    func hideBluetoothErrorPopUp() {
        DispatchQueue.main.async {
            self.bTErrorPopUPView.isHidden = true
        }
    }
    fileprivate func obdConnectionErrorAlert() {
        let alertVC = UIAlertController(title: "", message: "OBD got disconnected", preferredStyle: .alert)
        let connectAction = UIAlertAction(title: "Connect", style: .default) { (action) in
            DispatchQueue.main.async {
                self.startScanningForPheripherals()
            }
        }
        alertVC.addAction(connectAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    fileprivate func startScanningForPheripherals() {
        
        if (self.SCANNING_MODE) {
            print("self.bleManager.centralManager.state",self.centralManager.state.rawValue)
            
            self.hideBluetoothErrorPopUp()
            if (self.centralManager.state == .unauthorized) {
                self.hideDeviceDetailsPopUP()
                self.enableBluetoothPermisiion()
            } else if(self.centralManager.state == .poweredOn)  {
                self.changeConnectBtnState(state: 2)
                
                self.BT_SCANNING_TIMER = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.scanTimeOut), userInfo: nil, repeats: false)
                
                self.showLoading()
                self.showDeviceDetailsPopUP()
              //  self.bleManager.scan(nil)
                
                self.centralManager.scanForPeripherals(withServices: nil, options: nil)
            } else {
                self.changeConnectBtnState(state: 0)
                //                enableBluetoothVC.dismiss(animated: true, completion: nil)
                showBluetoothErrorPopUp()
            }
        } else {
            self.changeConnectBtnState(state: 0)
            //            enableBluetoothVC.dismiss(animated: true, completion: nil)
            //   textLog.write("===== bluetooth other states lo  undhi")
            showBluetoothErrorPopUp()
            //  textLog.write("===== Scannin mode is false")
            //  textLog.write("Scannin mode is false")
            // self.view.makeToast("Scannin mode is false")
        }
    }
    
    @objc func scanTimeOut() {
        self.showBluetoothErrorPopUp()
        //   textLog.write("======scanTimeOut function triggered=====\n")
        let alert = UIAlertController(title: "", message: "Scan timeout!! Please check if the device is switched on", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.changeConnectBtnState(state: 0)
        self.BT_SCANNING_TIMER?.invalidate()
        self.BT_SCANNING_TIMER = nil
        self.stopScanningForPeripherals()
    }
    
    fileprivate func stopScanningForPeripherals() {
        //  textLog.write("=====stopScanning ====\n")
        self.SCANNING_MODE = false
        self.hideLoading()
        self.centralManager.stopScan()
       // self.bleManager.stopScan()
    }
    fileprivate func showLoading()  {
        DispatchQueue.main.async {
            self.activityIndicatorView.isHidden = false
            self.activityIndicator.startAnimating()
            self.view.bringSubviewToFront(self.activityIndicatorView)
        }
    }
    
    fileprivate func hideLoading()  {
        DispatchQueue.main.async {
            self.activityIndicatorView.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    func checkIfCarStartedOrNot() -> Bool {
        
        
        return (self.pauseAndPlayBtn.tag == 0) ? false : true
    }
    
    fileprivate func changePauseAndPlayBtnState(state: Int) {
        self.pauseAndPlayBtn.tag = state
        switch state {
        case 0:
            self.pauseAndPlayBtn.setTitle("START", for: .normal)
        case 1:
            self.pauseAndPlayBtn.setTitle("STOP", for: .normal)
        default:
            break
        }
    }
    
    fileprivate func changeConnectBtnState(state:Int) {
        self.connectBtn.tag = state
        switch state {
        case 0:
            self.connectBtn.setTitle("Connect", for: .normal)
           // self.bleManager.centralManager.cancelPeripheralConnection(self.vGatePeripheral)
            
        case 1:
            self.connectBtn.setTitle("Connected", for: .normal)
            self.pauseAndPlayBtn.tag = 1
            
            self.BT_SCANNING_TIMER?.invalidate()
            self.BT_SCANNING_TIMER = nil
        case 2:
            self.connectBtn.setTitle("Searching...", for: .normal)
        case 3:
            self.connectBtn.setTitle("Connecting...", for: .normal)
        default:
            break
        }
    }
    
    fileprivate func enableBluetoothPermisiion() {
        DispatchQueue.main.async {
            let permissionAlertVC = UIAlertController(title: "", message: bluetoothPermissionMessage, preferredStyle: .alert)
            let settiingsAction = UIAlertAction(title: openSettingsText, style: .default) { (settingsAction) in
                self.openSettings()
            }
            permissionAlertVC.addAction(settiingsAction)
            self.present(permissionAlertVC, animated: true, completion: nil)
        }
    }
    
    fileprivate func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
    }
    
    fileprivate func showDeviceDetailsPopUP() {
        DispatchQueue.main.async {
            self.connectBluetoothPopupView.isHidden = false
            self.view.bringSubviewToFront(self.connectBluetoothPopupView)
        }
    }
    
    func initializeTheTransporter() {
        let serviceUUIDs: NSMutableArray = NSMutableArray()
        (["FFF0", "FFE0", "BEEF", "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"] as NSArray).enumerateObjects({ uuid, idx, stop in
            serviceUUIDs.add(CBUUID(string: uuid as! String))
        })
        
        self.transporter = LTBTLESerialTransporter.init(identifier: nil, serviceUUIDs: serviceUUIDs as! [CBUUID])
        NotificationCenter.default.addObserver(self, selector: #selector(onAdapterChangedState(notification:)), name: NSNotification.Name(rawValue: LTOBD2AdapterDidUpdateState), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onTransporterDidUpdateSignalStrength(notification:)), name: NSNotification.Name(rawValue: LTBTLESerialTransporterDidUpdateSignalStrength), object: nil)
        self.connectToLTBT()
    }
    
    func connectToLTBT() {
        let ma: NSMutableArray = [[LTOBD2CommandELM327_IDENTIFY.command(),
                                   LTOBD2CommandELM327_IGNITION_STATUS.command(),
                                   LTOBD2CommandELM327_READ_VOLTAGE.command(),
                                   LTOBD2CommandELM327_DESCRIBE_PROTOCOL.command(),
                                   
                                   LTOBD2PID_VIN_CODE_0902(),
                                   LTOBD2PID_FUEL_SYSTEM_STATUS_03.forMode1(),
                                   LTOBD2PID_OBD_STANDARDS_1C.forMode1(),
                                   LTOBD2PID_FUEL_TYPE_51.forMode1(),
                                   
                                   LTOBD2PID_ENGINE_LOAD_04.forMode1(),
                                   LTOBD2PID_COOLANT_TEMP_05.forMode1(),
                                   LTOBD2PID_SHORT_TERM_FUEL_TRIM_1_06.forMode1(),
                                   LTOBD2PID_LONG_TERM_FUEL_TRIM_1_07.forMode1(),
                                   LTOBD2PID_SHORT_TERM_FUEL_TRIM_2_08.forMode1(),
                                   LTOBD2PID_LONG_TERM_FUEL_TRIM_2_09.forMode1(),
                                   LTOBD2PID_FUEL_PRESSURE_0A.forMode1(),
                                   //  LTOBD2PID_INTAKE_MAP_0B.forMode1(),
                                   
                                   //   LTOBD2PID_ENGINE_RPM_0C.forMode1(),
                                   LTOBD2PID_VEHICLE_SPEED_0D.forMode1(),
                                   LTOBD2PID_TIMING_ADVANCE_0E.forMode1(),
                                   LTOBD2PID_INTAKE_TEMP_0F.forMode1(),
                                   LTOBD2PID_MAF_FLOW_10.forMode1(),
                                   LTOBD2PID_THROTTLE_11.forMode1(),
                                   
                                   LTOBD2PID_SECONDARY_AIR_STATUS_12.forMode1(),
                                   LTOBD2PID_OXYGEN_SENSORS_PRESENT_2_BANKS_13.forMode1()]]
        
        for i in 0..<8 {
            ma.add(LTOBD2PID_OXYGEN_SENSORS_INFO_1.pid(forSensor: UInt(i), mode: 1))
        }
        ma.addObjects(from: [LTOBD2PID_OXYGEN_SENSORS_PRESENT_4_BANKS_1D.forMode1(),
                             LTOBD2PID_AUX_INPUT_1E.forMode1(),
                             LTOBD2PID_RUNTIME_1F.forMode1(),
                             LTOBD2PID_DISTANCE_WITH_MIL_21.forMode1(),
                             LTOBD2PID_FUEL_RAIL_PRESSURE_22.forMode1(),
                             LTOBD2PID_FUEL_RAIL_GAUGE_PRESSURE_23.forMode1()])
        
        for i in 0..<8 {
            ma.add(LTOBD2PID_OXYGEN_SENSORS_INFO_2.pid(forSensor: UInt(i), mode: 1))
        }
        
        ma.addObjects(from:[LTOBD2PID_COMMANDED_EGR_2C.forMode1,
                            LTOBD2PID_EGR_ERROR_2D.forMode1,
                            LTOBD2PID_COMMANDED_EVAPORATIVE_PURGE_2E.forMode1,
                            LTOBD2PID_FUEL_TANK_LEVEL_2F.forMode1,
                            LTOBD2PID_WARMUPS_SINCE_DTC_CLEARED_30.forMode1,
                            LTOBD2PID_DISTANCE_SINCE_DTC_CLEARED_31.forMode1,
                            LTOBD2PID_EVAP_SYS_VAPOR_PRESSURE_32.forMode1,
                            LTOBD2PID_ABSOLUTE_BAROMETRIC_PRESSURE_33.forMode1])
        
        for i in 0..<8 {
            ma.add(LTOBD2PID_OXYGEN_SENSORS_INFO_3.pid(forSensor: UInt(i), mode: 1))
        }
        
        ma.addObjects(from:[LTOBD2PID_CATALYST_TEMP_B1S1_3C.forMode1,
                            LTOBD2PID_CATALYST_TEMP_B2S1_3D.forMode1,
                            LTOBD2PID_CATALYST_TEMP_B1S2_3E.forMode1,
                            LTOBD2PID_CATALYST_TEMP_B2S2_3F.forMode1,
                            LTOBD2PID_CONTROL_MODULE_VOLTAGE_42.forMode1,
                            LTOBD2PID_ABSOLUTE_ENGINE_LOAD_43.forMode1,
                            LTOBD2PID_AIR_FUEL_EQUIV_RATIO_44.forMode1,
                            LTOBD2PID_RELATIVE_THROTTLE_POS_45.forMode1,
                            LTOBD2PID_AMBIENT_TEMP_46.forMode1,
                            LTOBD2PID_ABSOLUTE_THROTTLE_POS_B_47.forMode1,
                            LTOBD2PID_ABSOLUTE_THROTTLE_POS_C_48.forMode1,
                            LTOBD2PID_ACC_PEDAL_POS_D_49.forMode1,
                            LTOBD2PID_ACC_PEDAL_POS_E_4A.forMode1,
                            LTOBD2PID_ACC_PEDAL_POS_F_4B.forMode1,
                            LTOBD2PID_COMMANDED_THROTTLE_ACTUATOR_4C.forMode1,
                            LTOBD2PID_TIME_WITH_MIL_4D.forMode1,
                            LTOBD2PID_TIME_SINCE_DTC_CLEARED_4E.forMode1,
                            LTOBD2PID_MAX_VALUE_FUEL_AIR_EQUIVALENCE_RATIO_4F.forMode1,
                            LTOBD2PID_MAX_VALUE_OXYGEN_SENSOR_VOLTAGE_4F.forMode1,
                            LTOBD2PID_MAX_VALUE_OXYGEN_SENSOR_CURRENT_4F.forMode1,
                            LTOBD2PID_MAX_VALUE_INTAKE_MAP_4F.forMode1,
                            LTOBD2PID_MAX_VALUE_MAF_AIR_FLOW_RATE_50.forMode1()])
        
        //    transporter.peripheral(self.vGatePeripheral, didDiscoverServices: nil)
        
        self.pids = NSArray.init(array: ma) as? [LTOBD2PID]
        print("Looking for adapter...")
        
        self.RPM_VALUE = 0
        self.SPEED_VALUE = 0
        
        self.transporter = LTBTLESerialTransporter.init(identifier: nil, serviceUUIDs: SupportedPeripheral.allUUIDs())
        self.transporter.connect { (inputStream, outputStream) in
            if(!(inputStream != nil)) {
                print("Could not connect to OBD2 adapter")
                return
            }
            DispatchQueue.main.sync {
                
                self.connectBluetoothPopupView.isHidden = true
                self.changeConnectBtnState(state: 1)
                Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.removeConnectionToPeriPheralTimer), userInfo: nil, repeats: false)
            }
            self.obd2Adapter = LTOBD2AdapterELM327.init(inputStream: inputStream!, outputStream: outputStream!)
            self.obd2Adapter.connect()
        }
        
        self.transporter.startUpdatingSignalStrength(withInterval: 1.0)
        
        
        self.RPM_VALUE = 0
        self.SPEED_VALUE = 0
        
    }
    
    @objc func removeConnectionToPeriPheralTimer() {
        self.CONNECTION_TO_PERIPHERAL_TIMER?.invalidate()
        self.CONNECTION_TO_PERIPHERAL_TIMER = nil
        self.hideLoading()
    }
    
    @objc func onAdapterChangedState(notification: Notification) {
        DispatchQueue.main.async {
            
            print("Adapter state changed -->", self.obd2Adapter.friendlyAdapterState)
            
            if(self.obd2Adapter.adapterState == OBD2AdapterStateConnected) {
                self.removeConnectionToPeriPheralTimer()
               
                self.updateSensorData()
            }
            
            if(self.obd2Adapter.adapterState == OBD2AdapterStateGone) {
                self.deviceTV.reloadData()
            }
            
            if(self.obd2Adapter.adapterState == OBD2AdapterStateUnsupportedProtocol) {
                DispatchQueue.main.async {
                    let message = "Adapter ready, but vehicle uses an unsupported protocol – \(self.obd2Adapter.friendlyVehicleProtocol)"
                    print(message)
                }
            }
        }
    }
    
    @objc func onTransporterDidUpdateSignalStrength(notification: Notification) {
        DispatchQueue.main.async {
            print("Signal strength --->", self.transporter.signalStrength.floatValue as Any)
        }
    }
    
    func updateSensorData() {
        let rpm: LTOBD2PID_ENGINE_RPM_0C = LTOBD2PID_ENGINE_RPM_0C.forMode1()
        let speed: LTOBD2PID_VEHICLE_SPEED_0D = LTOBD2PID_VEHICLE_SPEED_0D.forMode1()
        let temp: LTOBD2PID_COOLANT_TEMP_05 = LTOBD2PID_COOLANT_TEMP_05.forMode1()
        let trottle: LTOBD2PID_THROTTLE_11 = LTOBD2PID_THROTTLE_11.forMode1()
        
        obd2Adapter.transmitMultipleCommands([rpm, speed, temp, trottle], completionHandler: { commands in
            
            DispatchQueue.main.async(execute: { [weak self] in
                
                if let rpmValue = self?.getIntCharcatersFromString(str: rpm.formattedResponse) {
                    self?.RPM_VALUE = rpmValue
                }
                
                
                if let speedValue = self?.getIntCharcatersFromString(str: speed.formattedResponse) {
                    self?.SPEED_VALUE = speedValue
                }
                
                
                print("RPM_VALUE", self?.RPM_VALUE as Any)
                print("SPEED_VALUE", self?.SPEED_VALUE as Any)
               
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    self?.updateSensorData()
                })
            })
        })
    }
    
    
    fileprivate func getIntCharcatersFromString(str: String) -> Int? {
        let result = str.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        
        if let intValue = Int(result) {
            return intValue
        }
        return nil
    }
    
    fileprivate func onDisconnectAdapterClicked() {
        self.disconnect()
    }
    
    fileprivate func disconnect() {
        //self.obd2Adapter.disconnect()
    }
    
    
    private func setUpCarDetails() {
        guard let tdCarPathStr = self.TD_CAR_FILEPATH else {
            self.showAlert(message: "Test drive data is not available, Please check the downloads folder", viewController: self)
            return }
        
        guard let tdCarData: Data = NSData(contentsOfFile: tdCarPathStr) as Data? else {
            self.showAlert(message: "Test drive data is not available, Please check the downloads folder", viewController: self)
            return
        }
        
        do {
            let carDetailsData = try JSONDecoder().decode(TDCarAndTriggerData.self, from: tdCarData)
            self.MAIN_TRIGGERS = carDetailsData.featureData.filter { triggerData in
                return triggerData.triggerName != END_MESSAGE_TRIGGER
            }
            
            self.MAIN_TRIGGERS = self.MAIN_TRIGGERS.sorted { s1, s2 in
                return s1.order < s2.order
            }
            //  print("carDetailsData --->", carDetailsData)
        } catch {
            self.showAlert(message: "error when we are handling DATA", viewController: self)
        }
    }
    
    fileprivate func centralManagerCleanUp() {
        if (self.vGatePeripheral != nil) {
            self.centralManager.cancelPeripheralConnection(vGatePeripheral)
        }
    }

        fileprivate func ble_OBD_updateValue(obd_data: String) {
            let throttle: String =  (obd_data as NSString).substring(with: NSRange(location: 36, length: 2))
            
            let rpm: String =  (obd_data as NSString).substring(with: NSRange(location: 54, length: 4))
            self.RPM_VALUE = self.convertHexStringtoIntegerValue(string: rpm)
            
            let speed = (obd_data as NSString).substring(with: NSRange(location: 28, length: 2))
            self.SPEED_VALUE = self.convertHexStringtoIntegerValue(string: speed)
        }
        
        fileprivate func convertHexStringtoIntegerValue(string: String?) -> Int {
            let scanner = Scanner(string: string ?? "")
            var retval: UInt32 = UInt32()
            if scanner.scanHexInt32(&retval) {
                print("Invalid hex string")
                return 0
            }
            return Int(retval)
        }
        
        fileprivate func getService(peripheral: CBPeripheral?) -> CBService? {
            //  textLog.write("=====getService.. ====\n")
            let uuid = "49535343-FE7D-4AE5-8FA9-9FAFD205E455"
            for service in peripheral?.services ?? [] {
                if (service.uuid.uuidString == uuid) {
                    return service
                }
            }
            return nil
        }
        
        fileprivate func hex_to_string(data: NSData?) -> String? {
            let result: NSMutableData = NSMutableData.init(length: 2 * (data?.length)!)!
            let src = data!.bytes.assumingMemoryBound(to: UInt8.self)
            let dst = result.mutableBytes.assumingMemoryBound(to: UInt8.self)
            var t0: UInt8
            var t1: UInt8
            
            for i in 0..<(data?.length ?? 0) {
                t0 = UInt8(Int(src[i] ) >> 4)
                t1 = UInt8(Int(src[i] ) & 0x0f)
                
                dst[i * 2] = 48 + t0 + (t0 / 10) * 39
                dst[i * 2 + 1] = 48 + t1 + (t1 / 10) * 39
            }
            return String(data: result as Data, encoding: .ascii)
        }
    
    
    deinit {
        self.removeAllTimers()
    }
}

//MARK: AVAudioPlayerDelegate

extension TDTriggerDetailsVC: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("PLAYED_TRIGGERS ---->", PLAYED_TRIGGERS)
        guard let selectedPlayingIndex = self.SELECTED_PLAYING_TRIGGER_INDEX else { return  }
        self.updateAudioCompltedTriggers(index: selectedPlayingIndex)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        let triggerData = self.MAIN_TRIGGERS[selectedPlayingIndex]
        if triggerData.triggerName != WELCOME_MESSAGE_TRIGGER {
            self.playMarketingTriggersAutomatically(trigger: triggerData)
        }
    }
    
    func updateAudioCompltedTriggers(index:Int) {
        
        var triggerData = self.MAIN_TRIGGERS[index]
        triggerData.isAudioPlayed = true
        self.MAIN_TRIGGERS[index] = triggerData
        
        print("MAIN_TRIGGERS --->", MAIN_TRIGGERS)
        self.triggerCV.reloadData()
        self.scrollToMiddle(selectedRow: index)
    }
}
//MARK: FileManagerDelegate
extension TDTriggerDetailsVC: FileManagerDelegate {
    
}

//MARK: TRIGGERS LOGIC
extension TDTriggerDetailsVC {
    
    fileprivate func updateDistanceData() {
        if (SPEED_QUEUE_ARRAY.count > 0) {
            let lastSpeedvalue = self.SPEED_QUEUE_ARRAY.last ?? 0
            let speed_per_second: Float = Float(lastSpeedvalue) * 0.277778
            self.DISTANCE_TRAVELLED = self.DISTANCE_TRAVELLED + Int(speed_per_second)
        }
    }
    
    
    
    
}

//MARK:
extension TDTriggerDetailsVC: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager!) {
        switch central.state {
        case .unknown:
            print("Unknown")
        case .resetting:
            print("resetting")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            self.startScanningForPheripherals()
        case .unsupported:
            print("unsupported")
        @unknown default:
            break
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard (peripheral.name != nil) else {
            return
        }
        if !self.ALL_PERIPHERALS.contains(peripheral) {
            self.ALL_PERIPHERALS.append(peripheral)
        }
    }
    
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centralManager = CBCentralManager(delegate: nil, queue: nil)
        if vGatePeripheral != nil {
            self.centralManager.cancelPeripheralConnection(vGatePeripheral)
        }
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "connected_peripheral_UUID")
        self.initializeTheTransporter()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral==>",error as Any)
        if error != nil {
            self.changeConnectBtnState(state: 0)
            self.obdConnectAlert()
        }
    }
    
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let alert = UIAlertController(title: "", message: "Not able to connect to OBD please check the device connection with the vehicle and try again", preferredStyle: .alert)
        let connectAtion = UIAlertAction(title: "Try Again/Connect", style: .default) { (action) in
            self.changeConnectBtnState(state: 0)
            self.hideLoading()
          //  self.bleManager.centralManager.cancelPeripheralConnection(peripheral)
            self.centralManagerCleanUp()
            self.SCANNING_MODE = true
            self.startScanningForPheripherals()
        }
        alert.addAction(connectAtion)
        self.present(alert, animated: true, completion: nil)
    }
  
 
}


//MARK: BLEManagerDelegate
//extension TDTriggerDetailsVC: BLEManagerDelegate {
    
//    public func centralManagerDidUpdateState(_ central: CBCentralManager!) {
//        switch central.state {
//        case .unknown:
//            print("Unknown")
//        case .resetting:
//            print("resetting")
//        case .unauthorized:
//            print("unauthorized")
//        case .poweredOff:
//            print("poweredOff")
//        case .poweredOn:
//            self.startScanningForPheripherals()
//        case .unsupported:
//            print("unsupported")
//        @unknown default:
//            break
//        }
//    }
//
//    public func centralManager(_ central: CBCentralManager!, didDiscover peripheral: CBPeripheral!, advertisementData: [AnyHashable : Any]!, rssi RSSI: NSNumber!) {
//        guard (peripheral.name != nil) else {
//            return
//        }
//        if !self.ALL_PERIPHERALS.contains(peripheral) {
//            self.ALL_PERIPHERALS.append(peripheral)
//        }
//    }
//
//    public func centralManager(_ central: CBCentralManager!, didConnect peripheral: CBPeripheral!) {
//        self.bleManager.bledelegate = nil
//        self.bleManager.centralManager.cancelPeripheralConnection(peripheral)
//        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "connected_peripheral_UUID")
//        self.initializeTheTransporter()
//    }
    
    
    
//    public func centralManager(_ central: CBCentralManager!, didFailToConnect peripheral: CBPeripheral!, error: Error!) {
//        let alert = UIAlertController(title: "", message: "Not able to connect to OBD please check the device connection with the vehicle and try again", preferredStyle: .alert)
//        let connectAtion = UIAlertAction(title: "Try Again/Connect", style: .default) { (action) in
//            self.changeConnectBtnState(state: 0)
//            self.hideLoading()
//          //  self.bleManager.centralManager.cancelPeripheralConnection(peripheral)
//            self.centralManagerCleanUp()
//            self.SCANNING_MODE = true
//            self.startScanningForPheripherals()
//        }
//        alert.addAction(connectAtion)
//        self.present(alert, animated: true, completion: nil)
//    }
    
//}
    
   
    
//    public func centralManager(_ central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: Error!) {
//
//        print("didDisconnectPeripheral==>",error as Any)
//        if error != nil {
//            self.changeConnectBtnState(state: 0)
//            self.obdConnectAlert()
//        }
//    }
//


    


//MARK: Trigger Logics
extension TDTriggerDetailsVC {
    
    //MARK:- Check For Triggers
    
    /*
     If there is a drop of speed at 10km/h within 5 seconds.
     
     check for marketing player is playing or not
     */
    func checksoftbrakeTrigger() {
        
        if (self.checkIfCarStartedOrNot()) && (SPEED_QUEUE_ARRAY.count > 0) {
            let lastSpeedValue = self.SPEED_QUEUE_ARRAY.last ?? 0
            
            if(self.SPEED_QUEUE_ARRAY.count > 5) {
                let previousSpeedValue = self.SPEED_QUEUE_ARRAY[self.SPEED_QUEUE_ARRAY.count - 5]
                if isMarketingFeaturesTriggered {
                    return
                }
                
                if((previousSpeedValue - lastSpeedValue) >= 10) {
                    if !IS_SOFT_BRAKE_TRIGGER_PLAYED {
                        var indexValue = 0
                        
                        for (triggerIndex, triggerData) in self.MAIN_TRIGGERS.enumerated() {
                            let isAudioPalyed = triggerData.isAudioPlayed ?? false
                            if (triggerData.triggerName == SOFT_BRAKE_TRIGGERS) && (!isAudioPalyed) {
                                indexValue = triggerIndex
                                break
                            }
                        }
                        
                        if indexValue != 0 {
                            if (!isOBDTriggerisCalled) {
                                isOBDTriggerisCalled = true
                                self.SELECTED_PLAYING_TRIGGER_INDEX = indexValue
                               // IS_SOFT_BRAKE_TRIGGER_PLAYED = true
                                playOBDTriggers(indexValue: indexValue)
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*
     If speed is greater than 30 and RPM is greater than 2000
     
     Engine Pickup Triggers Contains Two Fetaures. First feature triggered when speed is greater than 30 and RPM is greater than 2000 and Second feature triggered speed is greater than 30 and RPM is greater than 2000.
     
     check for marketing player is playing or not
     */
    
    func checkPickUpTrigger() {
        print("pickupTriggerCalled-->")
        if (self.checkIfCarStartedOrNot()) && (SPEED_QUEUE_ARRAY.count > 0) && (RPM_QUEUE_ARRAY.count > 0)  {
//            let lastSpeed: String = self.speedQueue.lastObject as? String ?? ""
//            let lastPedal: String = self.rpmQueue.lastObject as? String ?? ""
            
            let lastSppedValue = SPEED_QUEUE_ARRAY.last ?? 0
            let lastPedalvalue = RPM_QUEUE_ARRAY.last ?? 0
            print("lastSpeed--->",lastSppedValue)
            print("lastPedal--->",lastPedalvalue)
            
            
            if isMarketingFeaturesTriggered {
                return
            }
            
            if(self.SPEED_QUEUE_ARRAY.count > 5) {
                
//                let previousSpeed: String = self.speedQueue.object(at: self.speedQueue.count - 2) as? String ?? ""
                let previousSpeedValue = self.SPEED_QUEUE_ARRAY[self.SPEED_QUEUE_ARRAY.count - 2]
                
                if (previousSpeedValue > 30) && (lastSppedValue > 30) && (lastPedalvalue >= 2000) {
                    var indexValue = 0
                    
                    for (triggerIndex, triggerData) in self.MAIN_TRIGGERS.enumerated() {
                        let isAudioPalyed = triggerData.isAudioPlayed ?? false
                        if (triggerData.triggerName == ENGINE_PICKUP_TRIGGERS) && (!isAudioPalyed) {
                            indexValue = triggerIndex
                            break
                        }
                    }
                   
                    if indexValue != 0 {
                        if (!isOBDTriggerisCalled) {
                            isOBDTriggerisCalled = true
                            IS_ENGINE_PICKUP_TRIGGER_PLAYED = true
                            self.SELECTED_PLAYING_TRIGGER_INDEX = indexValue
                            playOBDTriggers(indexValue: indexValue)
                        }
                    }
                }
            }
        }
    }
    
    /*
     If there is a pickup of speed at 10km/h within 5 seconds
     Speed is less than 20
     
     check for marketing player is playing or not
     */
    fileprivate func checkAccelerationTrigger() {
       
        
        if (self.checkIfCarStartedOrNot()) && (SPEED_QUEUE_ARRAY.count > 0) {
            print("Acceleration Block-->")
            let lastSppedValue = SPEED_QUEUE_ARRAY.last ?? 0
            
            // print("last speed Accelaration-->",lastSppedValue)
            if(self.SPEED_QUEUE_ARRAY.count > 5) {
                let previousSpeedValue = self.SPEED_QUEUE_ARRAY[self.SPEED_QUEUE_ARRAY.count - 5]
                
                if isMarketingFeaturesTriggered {
                    return
                }
                // ((previousSpeedValue > 0) && (lastSppedValue < 20))
                
                let speedDiff = lastSppedValue - previousSpeedValue
                
                if(speedDiff >= 10) && (lastSppedValue > 30) {
                    
                    var indexValue = 0
                    for (triggerIndex, triggerData) in self.MAIN_TRIGGERS.enumerated() {
                        let isAudioPalyed = triggerData.isAudioPlayed ?? false
                        if (triggerData.triggerName == SMOOTH_ACCELERATION_TRIGGERS) && (!isAudioPalyed) {
                            indexValue = triggerIndex
                            break
                        }
                    }
                    if indexValue != 0 {
                        if (!isOBDTriggerisCalled) {
                            isOBDTriggerisCalled = true
                            IS_SMOOTH_ACCELERATION_TRIGGER_PLAYED = true
                            self.SELECTED_PLAYING_TRIGGER_INDEX = indexValue
                            playOBDTriggers(indexValue: indexValue)
                        }
                    }
                }
            }
        }
    }
    
    /*
     speed between greater than 30 and lessthan 50 for >= 10 secs
     
     Cruise Control Triggers Contains Two Fetaures. First feature triggered when speed is 30 and 50 for >= 10 secs and Second feature triggered If Still speed is 30 and 50 for >= 10 (or) Next Time 30 and 50 for >= 10
     
     check for marketing player is playing or not
     */
    
    fileprivate func checkCruiseControlTypeTrigger() {
        print("Cruise Control Block-->")
        
        if (self.checkIfCarStartedOrNot()) && (SPEED_QUEUE_ARRAY.count > 0) {
            
            let lastSpeedValue = SPEED_QUEUE_ARRAY.last ?? 0
            if(self.SPEED_QUEUE_ARRAY.count > 11) {
           let previousSpeedValue = self.SPEED_QUEUE_ARRAY[self.SPEED_QUEUE_ARRAY.count - 10]
                
                if isMarketingFeaturesTriggered {
                    return
                }
                
                let lastSpeeValueData = (lastSpeedValue > 30) && (lastSpeedValue < 60)
                if((previousSpeedValue > 30)) && lastSpeeValueData {
                    
                    var indexValue = 0
                    for (triggerIndex, triggerData) in self.MAIN_TRIGGERS.enumerated() {
                        let isAudioPalyed = triggerData.isAudioPlayed ?? false
                        if (triggerData.triggerName == CRUISE_CONTROLTYPE_TRIGGERS) && (!isAudioPalyed) {
                            indexValue = triggerIndex
                            break
                        }
                    }
                    if indexValue != 0 {
                        if (!isOBDTriggerisCalled) {
                            isOBDTriggerisCalled = true
                            self.SELECTED_PLAYING_TRIGGER_INDEX = indexValue
                            IS_CRUISE_CONTROL_TRIGGER_PLAYED = true
                            playOBDTriggers(indexValue: indexValue)
                            
                        }
                    }
                }
            }
            
            
        }
    }
    
    /*
     If speed is 0 and RPM greater than 0 for 10 seconds
     Check For Other OBD Triggers played or not.
     
     check for marketing player is playing or not
     */
    
    
    fileprivate func checkForlowNVHTrigger() {
        print("LOW NVH Block-->")
        
        if (self.checkIfCarStartedOrNot()) {
            let lastSpeedValue = SPEED_QUEUE_ARRAY.last ?? 0
            let lastRPMValue = RPM_QUEUE_ARRAY.last ?? 0
            if(self.SPEED_QUEUE_ARRAY.count > 10) {
                let  previousSpeedValue = self.SPEED_QUEUE_ARRAY[self.SPEED_QUEUE_ARRAY.count-10]
                
                if isMarketingFeaturesTriggered {
                    return
                }
                if (((previousSpeedValue == 0) && (lastSpeedValue == 0)) && (lastRPMValue > 0)) {
                   
                    let welcomeTrigger = self.MAIN_TRIGGERS[0]
                    let isWelcomeTriggerPlayed = welcomeTrigger.isAudioPlayed ?? false
                    
                    //Check For Other Triggers are Played or not
                    let otherTriggersArePlayedorNot = (IS_CRUISE_CONTROL_TRIGGER_PLAYED || IS_SMOOTH_ACCELERATION_TRIGGER_PLAYED || IS_SOFT_BRAKE_TRIGGER_PLAYED || IS_ENGINE_PICKUP_TRIGGER_PLAYED)
                    
                    if  (isWelcomeTriggerPlayed) && (otherTriggersArePlayedorNot) {
                        var indexValue = 0
                        for (triggerIndex, triggerData) in self.MAIN_TRIGGERS.enumerated() {
                            let isAudioPalyed = triggerData.isAudioPlayed ?? false
                            if (triggerData.triggerName == ENGINE_IDLING_TRIGGERS) && (!isAudioPalyed) {
                                indexValue = triggerIndex
                                break
                            }
                        }
                        
                        if indexValue != 0 {
                            if (!isOBDTriggerisCalled) {
                                isOBDTriggerisCalled = true
                                SELECTED_PLAYING_TRIGGER_INDEX = indexValue
                                self.playOBDTriggers(indexValue: indexValue)
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func playOBDTriggers(indexValue: Int) {
        
        let triggerData = self.MAIN_TRIGGERS[indexValue]
        
        isMarketingFeaturesTriggered = true
        if let carTdPath = self.CAR_ASSET_PATH {
            let audioFilesArray = triggerData.audioFile
            if audioFilesArray.count > 0 {
                let feature_Audio_FilePath = "\(carTdPath)/\(audioFilesArray[0])"
                let soundFileURL: URL = URL(fileURLWithPath: feature_Audio_FilePath)
                
                if (self.audioPlayer != nil) {
                    if let volumeState: Float = self.audioPlayer?.volume {
                        self.audioPlayer?.stop()
                        self.audioPlayer = try! AVAudioPlayer(contentsOf: soundFileURL)
                        self.audioPlayer?.volume = volumeState
                    }
                } else {
                    self.audioPlayer = AVAudioPlayer()
                    self.audioPlayer = try! AVAudioPlayer.init(contentsOf: soundFileURL)
                }
            }
        }
        
        self.audioPlayer?.delegate = self
        self.audioPlayer?.prepareToPlay()
        
        if let _: Float = self.audioPlayer?.volume {
            let audioValue = muteAndUnMuteBtn.isSelected ? 0.0 : 1.0
            self.audioPlayer?.setVolume(Float(audioValue), fadeDuration: 1.0)
        }
        
        self.pauseAndPlayBtn.tag = 1
       
        self.audioPlayer?.stop()
        self.audioPlayer?.play()
        // setSessionPlayerOn()
        self.IS_USER_CLICKED_TRIGGER = false
        
        self.PLAY_MARKETING_TRIGGER_TIMER.invalidate()
        self.PLAY_MARKETING_TRIGGER_TIMER = Timer()
        
        let indexPath = IndexPath(item: indexValue, section: 0)
        self.triggerSelectedUpdateUIOnCellClick(indexPath: indexPath)
    }
    
}


//MARK: UI
extension TDTriggerDetailsVC {
    func setUpUI() {
        self.btErrorLabel.text = "Check your OBD device Connection or Check your bluetooth permission in Settings"
        self.setupTriggeredImageCV()
    }
    
    private func setupTriggeredImageCV() {
        self.triggerCV.showsVerticalScrollIndicator = false
        
        self.triggerCV.register(TDFeatureCVCell.nibFile, forCellWithReuseIdentifier: TDFeatureCVCell.RE_USE_IDENTIFIER)
        self.triggerCV.delegate = self
        self.triggerCV.dataSource = self
        
        self.deviceTV.register(PeripheralDetailTVCell.nibFile, forCellReuseIdentifier: PeripheralDetailTVCell.reUseIdentifier)
        self.deviceTV.delegate = self
        self.deviceTV.dataSource = self
        self.deviceTV.allowsSelection = true
        
    }
}

//MARK: UICollection view Delegate, UIcollection view DataSource
extension TDTriggerDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MAIN_TRIGGERS.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cvCell = collectionView.dequeueReusableCell(withReuseIdentifier: TDFeatureCVCell.RE_USE_IDENTIFIER, for: indexPath) as? TDFeatureCVCell else {
            return UICollectionViewCell()
        }
        guard let carTdPath = self.CAR_ASSET_PATH else { return cvCell}
        cvCell.CAR_ASSET_PATH = carTdPath
        let triggerData = self.MAIN_TRIGGERS[indexPath.item]
        
        cvCell.setUpFeatureUI(triggerData: triggerData)
        
        cvCell.featureDetailsView.layer.borderColor = UIColor.clear.cgColor
        cvCell.featureDetailsView.layer.borderWidth = 0
        
        if let playingIndex = self.SELECTED_PLAYING_TRIGGER_INDEX, (playingIndex == indexPath.item) {
            cvCell.featureDetailsView.layer.borderColor = TDColorCodes.primaryColor.cgColor
            cvCell.featureDetailsView.layer.borderWidth = 5
        }
        
        
        if triggerData.isAudioPlayed ?? false {
            cvCell.featureDetailsView.layer.borderColor = TDColorCodes.primaryColor.cgColor
            cvCell.featureDetailsView.layer.borderWidth = 5
        }
        
        
        
        return cvCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let triggerData = self.MAIN_TRIGGERS[indexPath.item]
        if let carTdPath = self.CAR_ASSET_PATH {
            let audioFilesArray = triggerData.audioFile
            if audioFilesArray.count > 0 {
                let feature_Audio_FilePath = "\(carTdPath)/\(audioFilesArray[0])"
                let soundFileURL: URL = URL(fileURLWithPath: feature_Audio_FilePath)
                
                if (self.audioPlayer != nil) {
                    if let volumeState: Float = self.audioPlayer?.volume {
                        self.audioPlayer?.stop()
                        self.audioPlayer = try! AVAudioPlayer(contentsOf: soundFileURL)
                        self.audioPlayer?.volume = volumeState
                    }
                } else {
                    self.audioPlayer = AVAudioPlayer()
                    self.audioPlayer = try! AVAudioPlayer.init(contentsOf: soundFileURL)
                }
                
                self.audioPlayer?.delegate = self
                self.audioPlayer?.prepareToPlay()
                
                if let _: Float = self.audioPlayer?.volume {
                    let audioValue = muteAndUnMuteBtn.isSelected ? 0.0 : 1.0
                    self.audioPlayer?.setVolume(Float(audioValue), fadeDuration: 1.0)
                }
                
                self.pauseAndPlayBtn.tag = 1
             
                self.audioPlayer?.stop()
                self.audioPlayer?.play()
                // setSessionPlayerOn()
                self.IS_USER_CLICKED_TRIGGER = true
                
                
                
                let indexPath = IndexPath(item: indexPath.item, section: 0)
                self.triggerSelectedUpdateUIOnCellClick(indexPath: indexPath)
                
            }
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let cellWidth = ((collectionView.frame.size.width)/3)
            return CGSize(width: cellWidth-10, height: cellWidth-35 )
            
        } else {
            let cellWidth = ((collectionView.frame.size.width)/4)
            return CGSize(width: cellWidth-10, height: cellWidth-30)
            
        }
    }
    
    fileprivate func scrollToMiddle(selectedRow: Int) {
        DispatchQueue.main.async {
            if self.MAIN_TRIGGERS.count > 0 {
                let indexPath = IndexPath(item: selectedRow, section: 0)
                self.triggerCV.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            }
        }
    }
    
}


//MARK: UITableviewDeleagate and UITableviewDataSource
extension TDTriggerDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ALL_PERIPHERALS.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tvCell = tableView.dequeueReusableCell(withIdentifier: PeripheralDetailTVCell.reUseIdentifier, for: indexPath) as? PeripheralDetailTVCell else {
            return UITableViewCell()
        }
        tvCell.setUpPheripheralDetails(peripheral: self.ALL_PERIPHERALS[indexPath.row])
        return tvCell
    }
    
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = self.ALL_PERIPHERALS[indexPath.row]
        
        self.vGatePeripheral = peripheral
        
        self.centralManager.connect(peripheral, options: nil)
      //  self.bleManager.centralManager.connect(peripheral, options: nil)
        self.stopScanningForPeripherals()
        self.changeConnectBtnState(state: 3)
        self.showLoading()
        print("Did select is triggered ---> ")
      //  self.bleManager.centralManager.cancelPeripheralConnection(peripheral)
        
        self.CONNECTION_TO_PERIPHERAL_TIMER = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.BTConnectionFailedTimer), userInfo: nil, repeats: false)
    }
    
    
    
    @objc func BTConnectionFailedTimer() {
        //   textLog.write("======Time out function triggered=====\n")
        self.CONNECTION_TO_PERIPHERAL_TIMER?.invalidate()
        self.CONNECTION_TO_PERIPHERAL_TIMER = nil
        
        if self.vGatePeripheral != nil {
            self.centralManager(self.centralManager, didFailToConnect: self.vGatePeripheral, error: nil)
        }
      
//        self.centralManager(self.bleManager.centralManager, didFailToConnect: self.bleManager.discoveredPeripheral, error: nil)
    }
    
}


