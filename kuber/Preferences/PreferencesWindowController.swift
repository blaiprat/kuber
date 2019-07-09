//
//  PreferencesWindowController.swift
//  kuber
//
//  Created by Blai Pratdesaba Pares on 08/07/2019.
//  Copyright © 2019 Blai Pratdesaba Pares. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        self.window?.orderOut(sender)
        return false
    }

}
