//
//  APIConstant.swift
//  TDKit
//
//  Created by Suneel on 20/07/22.
//

import Foundation

struct TDAPI {
    static let BASE_URL = "http://myhyundai.apprikart.com"
    static let ALL_CARS = BASE_URL + "/tablet_services/get_all_cars"
    
    static let ANALYTICS_BASE_URL = "http://hyundaianalytics.apprikart.com/"
    
    static let TD_VARINAT_AND_LANGUAGE_DETAILS = BASE_URL + "/testdrive_services/get_testdrive_car_details_v2/"
    
    static let TD_TEST_DRIVE_LOG = ANALYTICS_BASE_URL + "api/test_drive_log/"
    
    static let TEST_DRIVE_ASSETS = BASE_URL + "/testdrive_services/get_testdrive_car_assets"
}
