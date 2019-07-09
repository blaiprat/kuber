//
//  AppDelegate.swift
//  kuber
//
//  Created by Blai Pratdesaba Pares on 05/07/2019.
//  Copyright © 2019 Blai Pratdesaba Pares. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var kuberMenu: NSMenu!
    @IBOutlet weak var kuberMenuImage: NSImageView!
    
    
    let kuberImage = NSImage.init(named: "ImageMenu")
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var preferencesController: NSWindowController?
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        kuberImage!.isTemplate = true
        statusItem.image = kuberImage
        statusItem.menu = kuberMenu
        
        let canBeUsed = KubeCtlService.checkIfKubeCtlIsInstalled();
        if (canBeUsed) {
            populateMenu()
        }

    }
    
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    @objc func showPreferences(_ sender: Any) {
        if !(preferencesController != nil) {
            
            let storyboard = NSStoryboard.init(name: "Preferences", bundle: nil)
            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }
        
        
        if (preferencesController != nil) {
            preferencesController!.showWindow(sender)
        }
    }

    
    
    func populateMenu() {
        kuberMenu.removeAllItems()
        let contexts = KubeCtlService.getContexts()
        let currentContext = KubeCtlService.getCurrentContext();
        let menuItems = contexts.map {
            (label: String) -> NSMenuItem in
            let menuItem = NSMenuItem.init(title: label, action: #selector(selectTest(_:)), keyEquivalent: "")
            let selected = label.trimmingCharacters(in: .whitespacesAndNewlines) == currentContext.trimmingCharacters(in: .whitespacesAndNewlines);

            menuItem.state = selected ? NSControl.StateValue.on : NSControl.StateValue.off;
            return menuItem
        }
        
        

        menuItems.forEach(kuberMenu.addItem);
        
        kuberMenu.addItem(NSMenuItem.separator())
        kuberMenu.addItem(NSMenuItem.init(title: "Preferences", action: #selector(showPreferences(_:)), keyEquivalent:""))
        kuberMenu.addItem(NSMenuItem.init(title: "Quit", action: #selector(quitClicked(_:)), keyEquivalent:"Q"))
        
    }
    
    @objc func selectTest (_ sender: NSMenuItem){
        print("Test!", sender.title);
        let clusterName = sender.title;
        let sucess = KubeCtlService.setCurrentContext(clusterName: clusterName)
        if (sucess) {
            populateMenu()
        }
        
    }
    
    @objc func quitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    
}

