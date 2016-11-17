//
//  KeyBindingsPreferencesViewController.swift
//  TySimulator
//
//  Created by yinhun on 16/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import MASPreferences

class KeyBindingsPreferencesViewController: NSViewController, MASPreferencesViewController {
    
    // MARK: MASPreferencesViewController
    override var identifier: String? {
        get { return "KeyBindingsPreferences" }
        set { super.identifier = newValue }
    }
    
    @IBAction func onOnlyAvailableDevicesButtonClicked(_ sender: NSButton) {
        Preferences.onlyAvailableDevices = sender.state == NSOnState
    }
    
    @IBAction func onOnlyHasContentDevicesButtonClicked(_ sender: NSButton) {
        Preferences.onlyHasContentDevices = sender.state == NSOnState
    }
    
    var toolbarItemImage: NSImage! = NSImage(named: NSImageNamePreferencesGeneral)
    
    var toolbarItemLabel: String! = "Key Bindings"
}
