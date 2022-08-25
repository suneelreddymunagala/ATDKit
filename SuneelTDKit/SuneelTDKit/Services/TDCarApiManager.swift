//
//  ShowroomApiManager.swift
//  HyundaiSSC
//
//  Created by Suneel on 24/04/20.
//  Copyright © 2020 Apprikart. All rights reserved.
//

import Foundation


class TDCarApiManager {
     typealias getAllCarsDataHandler = (_ success:Bool,_ response: String,_ showroomCarsData:[TDCarData]?) -> ()
    
    static func getAllCarsData(url:String,postBody:[String:Any]?,completionHandler: @escaping getAllCarsDataHandler) {
        
        ApiManagerClass.singleTonObjectForApiMangerClass.GetJsonresponseData(urlString: url, postBody: postBody) { (data, errorStr) in
             guard let jsonData = data else {
               print("All cars Data",data as Any)
                          completionHandler(false,"",nil)
                           return
                       }
            //Conert data to json decoding
            do {
                    let decodedCarsData = try JSONDecoder().decode([TDCarData].self, from: jsonData)
             completionHandler(true,"",decodedCarsData)
            } catch let error {
                print("Modal failed")
                completionHandler(false,error.localizedDescription,nil)
            }
        }
    }
}
