//
//  GeneralPreferencesViewController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import MASPreferences

class GeneralPreferencesViewController: NSViewController, MASPreferencesViewController {
    
    @IBOutlet weak var isOnlyHasContentDevices: NSButton!
    @IBOutlet weak var isOnlyAvailableDevices: NSButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isOnlyAvailableDevices.state = Preferences.onlyAvailableDevices ? NSOnState : NSOffState
        self.isOnlyHasContentDevices.state = Preferences.onlyHasContentDevices ? NSOnState : NSOffState
    }
    
    // MARK: MASPreferencesViewController
    override var identifier: String? {
        get { return "GeneralPreferences" }
        set { super.identifier = newValue }
    }
    
    @IBAction func onOnlyAvailableDevicesButtonClicked(_ sender: NSButton) {
        Preferences.onlyAvailableDevices = sender.state == NSOnState
    }
    
    @IBAction func onOnlyHasContentDevicesButtonClicked(_ sender: NSButton) {
        Preferences.onlyHasContentDevices = sender.state == NSOnState
    }
    
    var toolbarItemImage: NSImage! = NSImage(named: NSImageNamePreferencesGeneral)

    var toolbarItemLabel: String! = "General"
}
