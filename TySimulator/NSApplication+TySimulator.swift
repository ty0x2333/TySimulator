//
//  NSApplication+TySimulator.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/15.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import HockeySDK

extension NSApplication: DM_SUUpdaterDelegate_DevMateInteraction {
    func showFeedbackWindow() {
        DevMateKit.showFeedbackDialog(nil, in: .modalMode)
    }
    
    func showPreferencesWindow() {
        let windowController = Preference.sharedWindowController()
        windowController.select(at: 0)
        windowController.showWindow(nil)
    }
    
    func showAboutWindow() {
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func checkForUpdates() {
        DM_SUUpdater.shared().delegate = self
        DM_SUUpdater.shared().checkForUpdates(NSApp)
    }
    
    // MARK: SUUpdaterDelegate_DevMateInteraction
    
    public func updaterDidNotFindUpdate(_ updater: DM_SUUpdater!) {
        log.warning("not found update: \(updater)")
    }
    
    public func updaterShouldCheck(forBetaUpdates updater: DM_SUUpdater!) -> Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
    
    public func isUpdater(inTestMode updater: DM_SUUpdater!) -> Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
}
