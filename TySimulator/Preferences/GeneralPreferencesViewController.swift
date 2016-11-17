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
    
    @IBOutlet weak var isOnlyAvailableDevices: NSButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isOnlyAvailableDevices.state = Preferences.onlyAvailableDevices ? NSOnState : NSOffState
    }
    
    // MARK: MASPreferencesViewController
    override var identifier: String? {
        get { return "GeneralPreferences" }
        set { super.identifier = newValue }
    }
    
    @IBAction func onOnlyAvailableDevicesButtonClicked(_ sender: NSButton) {
        Preferences.onlyAvailableDevices = sender.state == NSOnState
    }
    
    var toolbarItemImage: NSImage! = NSImage(named: NSImageNamePreferencesGeneral)

    var toolbarItemLabel: String! = "General"
}
