//
//  AppDelegate.swift
//  kuber
//
//  Created by Blai Pratdesaba Pares on 05/07/2019.
//  Copyright © 2019 Blai Pratdesaba Pares. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var kuberMenu: NSMenu!
    @IBOutlet weak var kuberMenuImage: NSImageView!
    
    
    let kuberImage = NSImage.init(named: "ImageMenu")
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var preferencesController: NSWindowController?
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        kuberImage!.isTemplate = true
        statusItem.button!.image = kuberImage
        statusItem.menu = kuberMenu
        
        // Make the app behave as a Menu Bar extra
        NSApp.setActivationPolicy(.accessory)
        
        let canBeUsed = KubeCtlService.checkIfKubeCtlIsInstalled();
        if (canBeUsed) {
            populateMenu()
        } else {
            let quit = dialogError()
            print("QuiT!", quit)
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
        let namespaces = KubeCtlService.getNamespaces();
        let currentNamespace = KubeCtlService.getCurrentNamespace();

        
        let menuItems = contexts.map {
            (label: String) -> NSMenuItem in
            let menuItem = NSMenuItem.init(title: label, action: #selector(selectTest(_:)), keyEquivalent: "")
            let selected = label.trimmingCharacters(in: .whitespacesAndNewlines) == currentContext.trimmingCharacters(in: .whitespacesAndNewlines);

            menuItem.state = selected ? NSControl.StateValue.on : NSControl.StateValue.off;
            return menuItem
        }
        
        let menuNamespaces = namespaces.map {
            (namespace: String) -> NSMenuItem in
            let namespaceMenuItem = NSMenuItem.init(title: namespace, action: #selector(selectNamespace(_:)), keyEquivalent: "")
            let selected = namespace == currentNamespace;
            namespaceMenuItem.state = selected ? NSControl.StateValue.on : NSControl.StateValue.off;
            
            return namespaceMenuItem
        }
        
        

        menuItems.forEach(kuberMenu.addItem);
        kuberMenu.addItem(NSMenuItem.separator())

        menuNamespaces.forEach(kuberMenu.addItem)
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
    
    @objc func selectNamespace (_ sender: NSMenuItem){
        print("namespace!", sender.title);
        let namespaceName = sender.title;
        let sucess = KubeCtlService.setCurrentNamespace(namespaceName: namespaceName);
        if (sucess) {
            populateMenu()
        }
    }
    
    
    @objc func quitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func dialogError() -> Bool {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = "We can't locate your kubectl command. Make sure it's installed. (Searching kubectl in `\(KubeCtlService.kubeCtlPath)`)"
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton(withTitle: "Ok")
        
        return alert.runModal() == .alertFirstButtonReturn

    }
    
    
}

