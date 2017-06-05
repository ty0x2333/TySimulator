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
        return NSApp.setActivationPolicy(state ? .regular : .accessory)
    }
    
//    public class func activate() -> Bool {
//        var error: Int = DMKevlarError.testError.rawValue
//        return _my_secret_activation_check!(&error).boolValue || DMKevlarError.noError == DMKevlarError(rawValue: error)
//    }
    
}


// MARK: Launch
extension NSApplication {
    
    class var isLaunchAtStartup: Bool {
        set {
            if newValue == isLaunchAtStartup {
                return
            }
            guard let loginItemsRef = LSSharedFileListCreate( nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileList? else {
                return
            }
            let itemReferences = itemReferencesInLoginItems()
            if newValue {
                let appUrl = NSURL(fileURLWithPath: Bundle.main.bundlePath)
                LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastReference, nil, nil, appUrl, nil, nil)
            } else if let itemRef = itemReferences.existingReference {
                LSSharedFileListItemRemove(loginItemsRef, itemRef);
            }
        }
        
        get {
            return itemReferencesInLoginItems().existingReference != nil
        }
    }
    
    private class func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItem?, lastReference: LSSharedFileListItem?) {
        let appURL: NSURL = NSURL.fileURL(withPath: Bundle.main.bundlePath) as NSURL
        let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue()
        let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
        
        let lastItemRef: LSSharedFileListItem = loginItems.lastObject as! LSSharedFileListItem
        
        for ref in loginItems.map({ $0 as! LSSharedFileListItem }) {
            if let itemURL = LSSharedFileListItemCopyResolvedURL(ref, 0, nil),
                (itemURL.takeRetainedValue() as NSURL).isEqual(appURL) {
                return (ref, lastItemRef)
            }
        }
        return (nil, lastItemRef)
    }

}
