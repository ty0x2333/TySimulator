//
//  MainMenuController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import HockeySDK

class MainMenuController: NSObject, NSMenuDelegate {
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var devices: [DeviceModel] = []
    
    lazy var quitMenuItem: NSMenuItem = self.makeQuitItem()
    var tagMap: Dictionary<String, Int> = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusItem.image = NSImage(named: "MenuIcon")
        statusItem.menu = makeMenu()
    }
    
    func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        
        self.devices = DeviceModel.devices()
        log.info("load devices: \(self.devices.count)")
        
        self.tagMap.removeAll()
        for i in 0 ..< self.devices.count {
            self.tagMap[devices[i].udid] = i
        }
        
        NSMenuItem.deviceMenuItems(self.devices, tagMap).forEach { (item) in
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(self.makePreferencesItem())
        menu.addItem(self.makeAboutItem())
        menu.addItem(self.makeFeedbackItem())
        menu.addItem(NSMenuItem.separator())
        menu.addItem(self.quitMenuItem)
        return menu
    }
    
    func makeQuitItem() -> NSMenuItem {
        let item = NSMenuItem()
        item.title = "Quit TySimulator"
        item.isEnabled = true
        item.target = NSApp
        item.action = #selector(NSApplication.terminate(_:))
        item.keyEquivalent = "q"
        return item;
    }
    
    func makeAboutItem() -> NSMenuItem {
        let item = NSMenuItem()
        item.title = "About TySimulator"
        item.isEnabled = true
        item.target = NSApp
        item.action = #selector(NSApplication.orderFrontStandardAboutPanel(_:))
        return item;
    }
    
    func makeFeedbackItem() -> NSMenuItem {
        let item = NSMenuItem()
        item.title = "Feedback..."
        item.isEnabled = true
        item.target = NSApp
        item.action = #selector(NSApplication.showFeedbackWindow)
        return item;
    }
    
    func makePreferencesItem() -> NSMenuItem {
        let item = NSMenuItem()
        item.title = "Preferences..."
        item.isEnabled = true
        item.target = NSApp
        item.action = #selector(NSApplication.showPreferencesWindow)
        return item;
    }
    
    // MARK: - NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        let bootedDevices = DeviceModel.bootedDevices()
        let bootedDeviceUDIDs = bootedDevices.map { (device) -> String in
            return device.udid
        }
        log.verbose("booted device udid: \(bootedDeviceUDIDs)")
        
        let bootedItemTags = bootedDeviceUDIDs.map { (udid) -> Int in
            return self.tagMap[udid]!
        }
        statusItem.menu?.items.forEach({ (item) in
            item.state = bootedItemTags.contains(item.tag) ? 1 : 0
        })
        
    }
}
