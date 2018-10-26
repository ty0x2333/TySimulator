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
        isLaunchAtStartup.state = NSApplication.isLaunchAtStartup ? .on : .off
        
        isOnlyAvailableDevices.title = NSLocalizedString("preference.general.only.available.device", comment: "preference")
        isOnlyAvailableDevices.state = preference.onlyAvailableDevices ? .on : .off
        
        isOnlyHasContentDevices.title = NSLocalizedString("preference.general.only.has.application", comment: "preference")
        isOnlyHasContentDevices.state = preference.onlyHasContentDevices ? .on : .off
        
        isAutomaticallyChecksForUpdates.title = NSLocalizedString("preference.general.auto.check.update", comment: "preference")
        isAutomaticallyChecksForUpdates.state = DM_SUUpdater.shared().automaticallyChecksForUpdates ? .on : .off
    }
    @IBAction func onLaunchAtStartupButtonClick(_ sender: NSButton) {
        NSApplication.isLaunchAtStartup = sender.state == .on
    }
    
    @IBAction func onOnlyAvailableDevicesButtonClick(_ sender: NSButton) {
        Preference.shared.onlyAvailableDevices = sender.state == .on
    }
    
    @IBAction func onOnlyHasContentDevicesButtonClick(_ sender: NSButton) {
        Preference.shared.onlyHasContentDevices = sender.state == .on
    }
    
    @IBAction func onAutomaticallyChecksForUpdatesButtonClick(_ sender: NSButton) {
        DM_SUUpdater.shared().automaticallyChecksForUpdates = sender.state == .on
    }
    
    @IBAction func onCheckForUpdatesButtonClick(_ sender: NSButton) {
        NSApp.checkForUpdates()
    }
    
    @IBAction func onFeedbackButtonClick(_ sender: NSButton) {
        NSApp.showFeedbackWindow()
    }
    
    // MARK: MASPreferencesViewController
    var viewIdentifier: String {
        return "GeneralPreferences"
    }
        
    var toolbarItemImage: NSImage? = NSImage(named: NSImage.preferencesGeneralName)

    var toolbarItemLabel: String? = NSLocalizedString("preference.general", comment: "preference")
}
