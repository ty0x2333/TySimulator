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
    var deviceItems: [NSMenuItem] = []
    
    lazy var quitMenuItem: NSMenuItem = {
        return NSMenuItem(title: "Quit TySimulator", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }()
    lazy var feedbackItem: NSMenuItem = {
        return NSMenuItem(title: "Feedback...", action: #selector(NSApplication.showFeedbackWindow), keyEquivalent: "")
    }()
    lazy var aboutItem: NSMenuItem = {
        return NSMenuItem(title: "About TySimulator", action: #selector(NSApplication.showAboutWindow), keyEquivalent: "")
    }()
    lazy var preferenceItem: NSMenuItem = {
        return NSMenuItem(title: "Preferences...", action: #selector(NSApplication.showPreferencesWindow), keyEquivalent: ",")
    }()
    lazy var checkForUpdatesItem: NSMenuItem = {
        return NSMenuItem(title: "Check For Updates...", action: #selector(NSApplication.checkForUpdates), keyEquivalent: "")
    }()
    
    var tagMap: Dictionary<String, Int> = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.statusItem.image = NSImage(named: "MenuIcon")
        
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(self.preferenceItem)
        menu.addItem(self.aboutItem)
        menu.addItem(self.feedbackItem)
        menu.addItem(self.checkForUpdatesItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(self.quitMenuItem)
        self.statusItem.menu = menu
        self.updateDeviceMenus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(devicesChangedNotification), name: Notification.Name(Device.DevicesChangedNotification), object: nil)
    }
    
    func updateDeviceMenus() {
        for it in self.deviceItems {
            self.statusItem.menu?.removeItem(it)
        }
        
        self.devices = Device.shared().devices
        log.info("load devices: \(self.devices.count)")
        
        self.tagMap.removeAll()
        for i in 0 ..< self.devices.count {
            self.tagMap[devices[i].udid] = i
        }
        
        self.deviceItems = NSMenuItem.deviceMenuItems(self.devices, tagMap)
        
        self.deviceItems.reversed().forEach { (item) in
            self.statusItem.menu?.insertItem(item, at: 0)
        }
    }
    
    // MARK: - NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        let bootedDevices = Device.bootedDevices()
        let bootedDeviceUDIDs = bootedDevices.map { (device) -> String in
            return device.udid
        }
        log.verbose("booted device udid: \(bootedDeviceUDIDs)")
        
        let bootedItemTags = bootedDeviceUDIDs.map { (udid) -> Int in
            return self.tagMap[udid]!
        }
        self.statusItem.menu?.items.forEach({ (item) in
            item.state = bootedItemTags.contains(item.tag) ? 1 : 0
        })
        
    }
    
    // MARK: Notification
    func devicesChangedNotification() {
        self.updateDeviceMenus()
    }
}
