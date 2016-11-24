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
        self.isOnlyAvailableDevices.state = Preference.shared().onlyAvailableDevices ? NSOnState : NSOffState
        self.isOnlyHasContentDevices.state = Preference.onlyHasContentDevices ? NSOnState : NSOffState
    }
    
    @IBAction func onOnlyAvailableDevicesButtonClicked(_ sender: NSButton) {
        Preference.shared().onlyAvailableDevices = sender.state == NSOnState
    }
    
    @IBAction func onOnlyHasContentDevicesButtonClicked(_ sender: NSButton) {
        Preference.onlyHasContentDevices = sender.state == NSOnState
    }
    
    // MARK: MASPreferencesViewController
    override var identifier: String? {
        get { return "GeneralPreferences" }
        set { super.identifier = newValue }
    }
    
    var toolbarItemImage: NSImage! = NSImage(named: NSImageNamePreferencesGeneral)

    var toolbarItemLabel: String! = "General"
}
