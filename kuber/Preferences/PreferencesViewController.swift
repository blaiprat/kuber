//
//  PreferencesViewController.swift
//  kuber
//
//  Created by Blai Pratdesaba Pares on 08/07/2019.
//  Copyright © 2019 Blai Pratdesaba Pares. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    @IBOutlet weak var kubeCTLPath: NSTextField!
    
    @IBOutlet weak var kubeCTLVersion: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        kubeCTLPath.isEditable = false
        kubeCTLPath.stringValue = KubeCtlService.kubeCtlPath
        do {
            kubeCTLVersion.stringValue = try KubeCtlService.getKubeCtlVersion()
        } catch {
            kubeCTLVersion.stringValue = "No KubeCtl found"
        }
        
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        
    }
    
    
    
}
