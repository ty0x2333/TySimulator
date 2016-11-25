//
//  NSApplication+TySimulator.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/15.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import HockeySDK

extension NSApplication {
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
}
