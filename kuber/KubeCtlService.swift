//
//  KubeCTLService.swift
//  kuber
//
//  Created by Blai Pratdesaba Pares on 05/07/2019.
//  Copyright © 2019 Blai Pratdesaba Pares. All rights reserved.
//

import Cocoa
import Foundation
import Shell

class KubeCtlService: NSObject {
    
    static var kubeCtlVersion: String?;
    static var shellInstance: Shell = Shell()
    static var cache: [String: Any?] = [:]
    public static let kubeCtlPath: String = "/usr/local/bin/kubectl";

    enum MyError: Error {
        case runtimeError(String)
    }
    
    
    static func log(_ message: String) {
        print(message)
    }
    

    @discardableResult static func shell(arguments args: [String]) throws -> String {
        let fullArgs = [kubeCtlPath] + args + ["--request-timeout=5s"]
        print("kubeCtlCalled with args \(fullArgs)")
        let result = shellInstance.capture(fullArgs)

        switch result {
        case .success(let output):
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        case .failure(let error):
            print("Error", error)
            throw error
        }

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
                log("Failed to load: \(error.localizedDescription)")
            }
            
        } catch let error as NSError {
            log("Failed to execute kubectl: \(error.localizedDescription)")
        }
        
        
    }
    
    static func checkIfKubeCtlIsInstalled() -> Bool {
        getKubeCtlVersion()
        let isValid = kubeCtlVersion != nil

        return isValid;
    }
    
    static func getContexts() -> [String] {
        if (cache["allContexts"] != nil) {
            print("Returning cache allContexts");
            return cache["allContexts"] as! [String];
        }
        do {
            print("getContexts invoked");
            let contextAsString = try shell(arguments: ["config", "view", "-o", "jsonpath={.contexts[*].name}"])
            let contexts = contextAsString.components(separatedBy: " ")
            
            print(contexts)
            cache["allContexts"] = contexts
            return contexts;
        } catch let error as NSError {
            log("Failed to execute kubectl: \(error.localizedDescription)")
            return []
        }
        
    }
    
    static func getCurrentContext() -> String {
        let CACHE_KEY = "currentContext"
        if (cache[CACHE_KEY] != nil) {
            print("Returning cache \(CACHE_KEY)");
            return cache[CACHE_KEY] as! String;
        }
        do {
            print("getCurrentContext invoked");
            let currentContext = try shell(arguments: ["config", "current-context"])
            print(currentContext)
            cache[CACHE_KEY] = currentContext
            return currentContext;
        } catch let error as NSError {
            log("Failed to execute kubectl: \(error.localizedDescription)")
            return ""
        }
    }
    
    static func setCurrentContext(clusterName: String) -> Bool {
        let CACHE_KEY = "currentContext"

        do {
            log("getCurrentContext invoked");
            try shell(arguments: ["config", "use-context", clusterName])
            cache[CACHE_KEY] = clusterName
            return true;
        } catch let error as NSError {
            print("Failed to execute kubectl: \(error.localizedDescription)")
            return false
        }
    }
    
    
    static func getNamespaces() -> [String] {
        do {
            let namespacesAsString = try shell(arguments: ["get", "ns", "-o", "jsonpath={.items[*].metadata.name}"]);
            let namespaces = namespacesAsString.components(separatedBy: " ")
            log(namespaces.joined(separator:" "))
            return namespaces
        } catch let error as NSError {
            print("Failed to execute kubectl: \(error.localizedDescription)")
            return []
        }
    }
    
    static func getCurrentNamespace() -> String? {
        do {
            let currentContext = getCurrentContext()
            let jsonPath = "jsonpath={.contexts[?(@.name=='\(currentContext)')].context.namespace}"
            let namespacesAsString = try shell(arguments: ["config", "view", "-o", jsonPath])
            
            return namespacesAsString
        } catch let error as NSError {
            print("Failed to execute kubectl: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func setCurrentNamespace(namespaceName: String)-> Bool {
        do {
            let currentContext = getCurrentContext()
            try shell(arguments: ["config", "set-context", currentContext, "--namespace=\(namespaceName)"])
            
            return true;
        } catch let error as NSError {
            print("Failed to execute kubectl: \(error.localizedDescription)")
            return false
        }
    }
}
