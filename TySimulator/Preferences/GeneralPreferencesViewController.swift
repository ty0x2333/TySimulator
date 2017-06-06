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
    
    @IBOutlet weak var checkForUpdatesButton: NSButton!
    @IBOutlet weak var feedbackButton: NSButton!
    @IBOutlet weak var applicationBox: NSBox!
    @IBOutlet weak var menuBox: NSBox!
    @IBOutlet weak var isOnlyHasContentDevices: NSButton!
    @IBOutlet weak var isOnlyAvailableDevices: NSButton!
    @IBOutlet weak var isLaunchAtStartup: NSButton!
    @IBOutlet weak var isAutomaticallyChecksForUpdates: NSButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let preference = Preference.shared
        
        checkForUpdatesButton.title = NSLocalizedString("preference.general.check.update", comment: "preference")
        feedbackButton.title = NSLocalizedString("preference.general.feedback", comment: "preference")
        
        applicationBox.title = NSLocalizedString("preference.general.application", comment: "preference")
        menuBox.title = NSLocalizedString("preference.general.menu", comment: "preference")
        
        isLaunchAtStartup.title = NSLocalizedString("preference.general.launch.startup", comment: "preference")
        isLaunchAtStartup.state = NSApplication.isLaunchAtStartup ? NSOnState : NSOffState
        
        isOnlyAvailableDevices.title = NSLocalizedString("preference.general.only.available.device", comment: "preference")
        isOnlyAvailableDevices.state = preference.onlyAvailableDevices ? NSOnState : NSOffState
        
        isOnlyHasContentDevices.title = NSLocalizedString("preference.general.only.has.application", comment: "preference")
        isOnlyHasContentDevices.state = preference.onlyHasContentDevices ? NSOnState : NSOffState
        
        isAutomaticallyChecksForUpdates.title = NSLocalizedString("preference.general.auto.check.update", comment: "preference")
        isAutomaticallyChecksForUpdates.state = DM_SUUpdater.shared().automaticallyChecksForUpdates ? NSOnState : NSOffState
    }
    @IBAction func onLaunchAtStartupButtonClicked(_ sender: NSButton) {
        NSApplication.isLaunchAtStartup = sender.state == NSOnState
    }
    
    @IBAction func onOnlyAvailableDevicesButtonClicked(_ sender: NSButton) {
        Preference.shared.onlyAvailableDevices = sender.state == NSOnState
    }
    
    @IBAction func onOnlyHasContentDevicesButtonClicked(_ sender: NSButton) {
        Preference.shared.onlyHasContentDevices = sender.state == NSOnState
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

    var toolbarItemLabel: String! = NSLocalizedString("preference.general", comment: "preference")
}
