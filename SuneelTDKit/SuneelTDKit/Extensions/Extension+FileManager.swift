//
//  Extension+FileManager.swift
//  HyundaiSSC
//
//  Created by Suneel on 21/07/22.
//  Copyright © 2022 Apprikart. All rights reserved.
//

import Foundation

extension FileManager {
    func getTDDocumnetaryPath() -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!
        return documentPath
    }
    
    /* Check for SSC folder is available or not */
    func getAllFolderNamesFromSSCApp() -> [String]? {
        var documentryPath = FileManager().getTDDocumnetaryPath()        
        documentryPath.append(contentsOf: "/HyundaiSSC")
     
        if (FileManager.default.fileExists(atPath:documentryPath))  {
            do {
                let fileList = try FileManager.default.contentsOfDirectory(atPath: documentryPath)
                return fileList
            } catch let error {
                print("error ---->",error)
                return nil
            }
        }
            return nil
    }
    
    
    /* Get SSC folder name*/
    func getTDAssetFolderName(filePath str: String) -> [String]? {
        var documentryPath = FileManager().getTDDocumnetaryPath()
        documentryPath.append(contentsOf: str)
     
        if (FileManager.default.fileExists(atPath:documentryPath))  {
            do {
                let fileList = try FileManager.default.contentsOfDirectory(atPath: documentryPath)
                return fileList
            } catch let error {
                print("error ---->",error)
                return nil
            }
        }
            return nil
    }
    
}
