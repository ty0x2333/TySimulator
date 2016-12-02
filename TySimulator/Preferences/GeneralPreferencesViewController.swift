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
    @IBOutlet weak var isLaunchAtStartup: NSButton!
    @IBOutlet weak var isAutomaticallyChecksForUpdates: NSButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let preference = Preference.shared()
        self.isLaunchAtStartup.state = NSApplication.isLaunchAtStartup ? NSOnState : NSOffState
        self.isOnlyAvailableDevices.state = preference.onlyAvailableDevices ? NSOnState : NSOffState
        self.isOnlyHasContentDevices.state = preference.onlyHasContentDevices ? NSOnState : NSOffState
        self.isAutomaticallyChecksForUpdates.state = DM_SUUpdater.shared().automaticallyChecksForUpdates ? NSOnState : NSOffState
    }
    @IBAction func onLaunchAtStartupButtonClicked(_ sender: NSButton) {
        NSApplication.isLaunchAtStartup = sender.state == NSOnState
    }
    
    @IBAction func onOnlyAvailableDevicesButtonClicked(_ sender: NSButton) {
        Preference.shared().onlyAvailableDevices = sender.state == NSOnState
    }
    
    @IBAction func onOnlyHasContentDevicesButtonClicked(_ sender: NSButton) {
        Preference.shared().onlyHasContentDevices = sender.state == NSOnState
    }
    
    @IBAction func onAutomaticallyChecksForUpdatesButtonClicked(_ sender: NSButton) {
        DM_SUUpdater.shared().automaticallyChecksForUpdates = sender.state == NSOnState
    }
    
    @IBAction func onCheckForUpdatesButtonClicked(_ sender: NSButton) {
        NSApp.checkForUpdates()
    }
    
    @IBAction func onFeedbackButtonClicked(_ sender: NSButton) {
        NSApp.showFeedbackWindow()
    }
    
    // MARK: MASPreferencesViewController
    override var identifier: String? {
        get { return "GeneralPreferences" }
        set { super.identifier = newValue }
    }
    
    var toolbarItemImage: NSImage! = NSImage(named: NSImageNamePreferencesGeneral)

    var toolbarItemLabel: String! = "General"
}
