//
//  AppDelegate.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import HockeySDK

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DevMateKit.sendTrackingReport(nil, delegate: nil)
        
        BITHockeyManager.shared().configure(withIdentifier: "4809e9695f5749449758cf7ec79710f5")
        BITHockeyManager.shared().crashManager.isAutoSubmitCrashReport = true
        BITHockeyManager.shared().start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

