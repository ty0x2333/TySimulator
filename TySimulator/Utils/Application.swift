//
//  Application.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/12/1.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation

import HockeySDK

extension NSApplication {
    func showFeedbackWindow() {
        DevMateKit.showFeedbackDialog(nil, in: .modalMode)
    }
    
    func showPreferencesWindow() {
        let windowController = Preference.sharedWindowController
        windowController.select(at: 0)
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showAboutWindow() {
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func checkForUpdates() {
        DM_SUUpdater.shared().checkForUpdates(NSApp)
    }
    
    public class func toggleDockIcon(showIcon state: Bool) -> Bool {
        var result: Bool
        if state {
            result = NSApp.setActivationPolicy(NSApplicationActivationPolicy.regular)
        } else {
            result = NSApp.setActivationPolicy(NSApplicationActivationPolicy.accessory)
        }
        return result
    }
    
    public class func activate() -> Bool {
        var error: Int = DMKevlarError.testError.rawValue
        return _my_secret_activation_check!(&error).boolValue || DMKevlarError.noError == DMKevlarError(rawValue: error)
    }
    
}


// MARK: Launch
extension NSApplication {
    
    class var isLaunchAtStartup: Bool {
        set {
            if newValue == self.isLaunchAtStartup {
                return
            }
            let itemReferences = itemReferencesInLoginItems()
            if let loginItemsRef = LSSharedFileListCreate( nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileList? {
                if newValue {
                    let appUrl = NSURL(fileURLWithPath: Bundle.main.bundlePath)
                    LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastReference, nil, nil, appUrl, nil, nil)
                } else {
                    if let itemRef = itemReferences.existingReference {
                        LSSharedFileListItemRemove(loginItemsRef, itemRef);
                    }
                }
            }
        }
        
        get {
            return (self.itemReferencesInLoginItems().existingReference != nil)
        }
    }
    
    private class func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItem?, lastReference: LSSharedFileListItem?) {
        if let appURL : NSURL = NSURL.fileURL(withPath: Bundle.main.bundlePath) as NSURL? {
            if let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileList? {
                
                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
                let lastItemRef: LSSharedFileListItem = loginItems.lastObject as! LSSharedFileListItem
                
                for i in 0 ..< loginItems.count {
                    let currentItemRef: LSSharedFileListItem = loginItems.object(at: i) as! LSSharedFileListItem
                    if let itemURL = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil) {
                        if (itemURL.takeRetainedValue() as NSURL).isEqual(appURL) {
                            return (currentItemRef, lastItemRef)
                        }
                    }
                }
                return (nil, lastItemRef)
            }
        }
        
        return (nil, nil)
    }

}
