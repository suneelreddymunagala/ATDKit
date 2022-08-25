//
//  ApiManagerClass.swift
//  HyundaiSSC
//
//  Created by Suneel on 04/03/20.
//  Copyright © 2020 Apprikart. All rights reserved.
//

import Foundation
    enum ErrorText:String {
        case internet = "No internet conncetion"
        case alert = "Something wet wrong"
        case JsonCodable = "Codable isssue"
    }


    class ApiManagerClass:NSObject  {
    
        static let singleTonObjectForApiMangerClass = ApiManagerClass()
        private override init() {
        }
        //CommonPost Method Using Genaric
        func postJsondata(url urlString:String,isComingFromVCAPI: Bool=false,postBody:[String:Any]?, headers: [String:String]?, complitionHandler:@escaping(_ responseData:Data?, _ errorString:String?) -> ()) {
             var task: URLSessionTask?
            //Check Internet

            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = isComingFromVCAPI ? 120 : 60
            configuration.timeoutIntervalForRequest = isComingFromVCAPI ? 120 : 60
            if #available(iOS 11, *) {
                configuration.waitsForConnectivity = false
            }
            
            let session = URLSession(configuration: configuration)
            guard let url = URL(string: urlString) else {
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
                 request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                  if let headersData = headers {
                      for (key,value) in headersData {
                          request.addValue(value, forHTTPHeaderField: key)
                      }
                  }
            do {
                let jsonBody = try JSONSerialization.data(withJSONObject: postBody!, options:.prettyPrinted)
                request.httpBody = jsonBody
            } catch {
                print("Error Block")
            }
            task = session.dataTask(with: request) {(data, response, error) in
                
                print("response --->", response as Any)
                print("error --->", error as Any)
                guard error == nil else {
                    complitionHandler(nil,error?.localizedDescription)
                    return
                }
                if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    //Checkong response
                    //convert data to json
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    print("Json data from Response--->",json ?? [])
                    complitionHandler(data,nil)
                } else {
                    let response = response as? HTTPURLResponse
                    print("response--->",response as Any)
                    if let statusCode =  response?.statusCode{
                        let statusCodeTostring:String = String(statusCode)
                        complitionHandler(nil,statusCodeTostring)
                    }
                    
                }
                }
            task?.resume()
        }
        
        //Common Get method using jsonserialization
        func GetJsonresponseData(urlString:String, isComingFromVCAPI: Bool=false, postBody:[String:Any]?,complitionHandler:@escaping(_ responseData:Data?,_ error:String?) -> ())
        {
            var task: URLSessionTask?
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForResource = isComingFromVCAPI ? 120 : 60
            configuration.timeoutIntervalForRequest = isComingFromVCAPI ? 120 : 60
            
            if #available(iOS 11, *) {
                configuration.waitsForConnectivity = true
            }
            
            let session = URLSession(configuration: configuration)
            guard let url = URL(string: urlString) else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let postData = postBody {
                do{
                    let jsonBody = try JSONSerialization.data(withJSONObject:postData, options:.prettyPrinted)
                    request.httpBody = jsonBody
                }catch{
                    print("Error Block")
                }
            }
            
            if let requestHttpBody = request.httpBody {
                    if let bodyJsonStr = String(data: requestHttpBody, encoding: .utf8) {
                       print("bodyJsonStr", bodyJsonStr)
                    }
            }
          
            task = session.dataTask(with: request) {(data, response, error) in
                
                guard error == nil else {                    
                    complitionHandler(nil,error?.localizedDescription)
                    return
                }
                if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    //convert data to json
                  //  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                 // print("Showing josnResponse = \(String(describing: json))")
                    complitionHandler(data,nil)
                }
                else {
                    let response = response as? HTTPURLResponse
                    if let statusCode =  response?.statusCode{
                        let statusCodeTostring:String = String(statusCode)
                        complitionHandler(nil,statusCodeTostring)
                    }
                }
                }
            
            task?.resume()
        }
        
        
}


