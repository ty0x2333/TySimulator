//
//  MainMenuController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject, NSMenuDelegate {
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    var devices: [DeviceModel] = []
    
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
        
        self.devices.forEach { (device) in
            menu.addItem(NSMenuItem.deviceMenuItem(device))
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(makeQuitItem())
        return menu
    }
    
    func makeQuitItem() -> NSMenuItem {
        let item = NSMenuItem()
        item.title = "Quit TySimulator"
        item.isEnabled = true
        item.target = self
        item.action = #selector(quit(_:))
        return item;
    }
    
    // MARK: - Actions
    
    func quit(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
