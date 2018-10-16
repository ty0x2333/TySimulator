//
//  AppDelegate.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics

class AppDelegate: NSObject, NSApplicationDelegate, DevMateKitDelegate {
    @IBOutlet weak var mainMenuController: MainMenuController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSViewController.awake()
        NSTextView.awake()
        
        Fabric.with([Crashlytics.self])
        #if DEBUG
            Fabric.sharedSDK().debug = true
        #endif
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
        
        NSApplication.toggleDockIcon(showIcon: false)
        DevMateKit.sendTrackingReport(nil, delegate: nil)
        DM_SUUpdater.shared().delegate = self
        
        DispatchQueue.global().async {
            Simulator.shared.updateDeivces()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        LRUCache.shared.save()
    }
    
    // MARK: SUUpdaterDelegate_DevMateInteraction
    
    public func updaterDidNotFindUpdate(_ updater: DM_SUUpdater) {
        log.warning("not found update: \(updater)")
    }
    
    @nonobjc public func updaterShouldCheck(forBetaUpdates updater: DM_SUUpdater) -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    @objc public func isUpdater(inTestMode updater: DM_SUUpdater) -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}
