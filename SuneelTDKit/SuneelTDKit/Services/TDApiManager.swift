//
//  TDApiManager.swift
//  TDKit
//
//  Created by Suneel on 20/07/22.
//

import Foundation
struct TDAPIManager {
    
    typealias handler = (_ success:Bool,_ response: String,_ hmmSiteData: [TestDriveAssestsData]?) -> ()
    
    static func getTDAssestsData(url:String,postBody:[String:Any]?,completionHandler: @escaping handler){
        
        ApiManagerClass.singleTonObjectForApiMangerClass.GetJsonresponseData(urlString: url, postBody: postBody) { (data, errorStr) in
            guard let jsonData = data else {
                print("wronf data",data as Any)
                completionHandler(false,"",nil)
                return
            }
            
            //Conert data to jsod decoding
            let unWrappeddata = try? JSONDecoder().decode([TestDriveAssestsData].self, from: jsonData)
            guard let data = unWrappeddata else{
                completionHandler(false,"",nil)
                return
            }
                completionHandler(true,"",data)
        }
    }
    
    
    
    typealias variantDetailsHandler = (_ success:Bool,_ response: String,_ hmmSiteData: TDVariantAndLangaugeData?) -> ()
    
    static func getVariantAndLanguagedetails(url:String,postBody:[String:Any]?,completionHandler: @escaping variantDetailsHandler){
        
        ApiManagerClass.singleTonObjectForApiMangerClass.GetJsonresponseData(urlString: url, postBody: postBody) { (data, errorStr) in
            guard let jsonData = data else {
                print("wronf data",data as Any)
                completionHandler(false,"",nil)
                return
            }
            
            //Conert data to jsod decoding
            let unWrappeddata = try? JSONDecoder().decode(TDVariantAndLangaugeData.self, from: jsonData)
            guard let data = unWrappeddata else{
                completionHandler(false,"",nil)
                return
            }
                completionHandler(true,"",data)
        }
    }
    
    
    //MARK: - Update Logs
    typealias updateLogHandler = (_ success:Bool,_ response: String) -> ()
    static func updateTDLogsData(url:String,postBody:[String:Any]?, headers: [String: String]?,completionHandler: @escaping updateLogHandler) {
        
        ApiManagerClass.singleTonObjectForApiMangerClass.postJsondata(url: url, postBody: postBody, headers: headers) { (data, errorStr) in
            guard data != nil else {
                completionHandler(false,"")
                return
            }
            completionHandler(true,"")
        }
    }
}
