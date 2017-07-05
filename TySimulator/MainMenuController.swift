//
//  MainMenuController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject {
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var devices: [DeviceModel] = []
    var deviceItems: [NSMenuItem] = []
    
    lazy var quitMenuItem: NSMenuItem = {
        return NSMenuItem(title: NSLocalizedString("menu.quit", comment: "menu"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }()
    lazy var aboutItem: NSMenuItem = {
        return NSMenuItem(title: NSLocalizedString("menu.about", comment: "menu"), action: #selector(NSApplication.showAboutWindow), keyEquivalent: "")
    }()
    lazy var preferenceItem: NSMenuItem = {
        return NSMenuItem(title: NSLocalizedString("menu.preference", comment: "menu"), action: #selector(NSApplication.showPreferencesWindow), keyEquivalent: ",")
    }()
    
    var tagMap: [String: Int] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let icon = NSImage(named: "MenuIcon")
        icon?.isTemplate = true
        statusItem.image = icon
        
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(preferenceItem)
        menu.addItem(aboutItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitMenuItem)
        statusItem.menu = menu
        updateDeviceMenus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(devicesChangedNotification), name: Device.DevicesChangedNotification, object: nil)
    }
    
    func updateDeviceMenus() {
        for it in deviceItems {
            statusItem.menu?.removeItem(it)
        }
        
        devices = Device.shared.devices
        log.info("load devices: \(devices.count)")
        
        tagMap.removeAll()
        for i in 0 ..< devices.count {
            tagMap[devices[i].udid] = i
        }
        
        deviceItems = NSMenuItem.deviceMenuItems(devices, tagMap)
        
        deviceItems.reversed().forEach { (item) in
            statusItem.menu?.insertItem(item, at: 0)
        }
    }
    
    // MARK: Notification
    func devicesChangedNotification() {
        updateDeviceMenus()
    }
}

extension MainMenuController: NSMenuDelegate {
    // MARK: - NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        let bootedDevices = Device.bootedDevices()
        let bootedDeviceUDIDs = bootedDevices.map { (device) -> String in
            return device.udid
        }
        log.verbose("booted device udid: \(bootedDeviceUDIDs)")
        
        let bootedItemTags = bootedDeviceUDIDs.map { (udid) -> Int in
            return tagMap[udid]!
        }
        statusItem.menu?.items.forEach({ (item) in
            item.state = bootedItemTags.contains(item.tag) ? 1 : 0
        })
        
    }
}
