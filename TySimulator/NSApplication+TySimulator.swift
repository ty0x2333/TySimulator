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
        BITHockeyManager.shared().feedbackManager.showFeedbackWindow()
    }
    
    func showPreferencesWindow() {
        // MARK: TODO
        Preferences.sharedWindowController().showWindow(nil)
    }
}
