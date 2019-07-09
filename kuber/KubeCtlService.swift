//
//  KubeCTLService.swift
//  kuber
//
//  Created by Blai Pratdesaba Pares on 05/07/2019.
//  Copyright © 2019 Blai Pratdesaba Pares. All rights reserved.
//

import Cocoa
import Foundation


class KubeCtlService: NSObject {
    
    static var kubeCtlVersion: String?;
    static let kubeCtlPath: String = "/usr/local/bin/kubectl";
    
    static func shell(arguments args: [String]) throws -> String {
        let task = Process()
        task.launchPath = kubeCtlPath
        task.arguments = args
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        try task.run()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(decoding: outputData, as: UTF8.self)
        let error = String(decoding: errorData, as: UTF8.self)
        task.waitUntilExit()
 
        
        return(output)
    }
    
    static func getKubeCtlVersion() {
        do {
            let version = try shell(arguments: ["version", "--client", "-o", "json"]);
            
            let data = version.data(using: .utf8)!
            //        let versionDictionary[String:String] = [;]
            do {
                // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
                    if let entry = json["clientVersion"] as? [String:String] {
                        
                        kubeCtlVersion = entry["gitVersion"]
                        
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        } catch let error as NSError {
            print("Failed to execute kubectl: \(error.localizedDescription)")
        }
        
        
    }
    
    class func checkIfKubeCtlIsInstalled() -> Bool {
        getKubeCtlVersion()
        let isValid = kubeCtlVersion != nil
        print("isValid", isValid, kubeCtlVersion);
        return isValid;
    }
    
    class func getContexts() -> [String] {
        do {
            print("getContexts invoked");
            let contextAsString = try shell(arguments: ["config", "view", "-o", "jsonpath='{.contexts[*].name}'"])
            let contexts = contextAsString.components(separatedBy: " ")
            let cleanedContext = contexts.map {$0.replacingOccurrences(of:"'" ,with:"")}
            print(cleanedContext)
            return cleanedContext;
        } catch let error as NSError {
            print("Failed to execute kubectl: \(error.localizedDescription)")
            return []
        }
        
    }
    
    class func getCurrentContext() -> String {
        do {
            print("getCurrentContext invoked");
            let contextAsString = try shell(arguments: ["config", "current-context"])
            print(contextAsString)
            return contextAsString;
        } catch let error as NSError {
            print("Failed to execute kubectl: \(error.localizedDescription)")
            return ""
        }
    }
    
    class func setCurrentContext(clusterName: String) -> Bool {
        do {
            print("getCurrentContext invoked");
            let contextAsString = try shell(arguments: ["config", "use-context", clusterName])

            return true;
        } catch let error as NSError {
            print("Failed to execute kubectl: \(error.localizedDescription)")
            return false
        }
    }
    

}
