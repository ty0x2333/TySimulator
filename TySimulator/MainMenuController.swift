//
//  MainMenuController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover: NSPopover = NSPopover()
    let quitMenuItem: NSMenuItem = NSMenuItem(title: NSLocalizedString("menu.quit", comment: "menu"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    let aboutItem: NSMenuItem = NSMenuItem(title: NSLocalizedString("menu.about", comment: "menu"), action: #selector(NSApplication.showAboutWindow), keyEquivalent: "")
    let preferenceItem: NSMenuItem = NSMenuItem(title: NSLocalizedString("menu.preference", comment: "menu"), action: #selector(NSApplication.showPreferencesWindow), keyEquivalent: ",")
    
    var monitor: Any?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        popover.contentViewController = AppMenuViewController(nibName: "AppMenuViewController", bundle: nil)
        
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
            button.target = self
            button.action = #selector(MainMenuController.togglePopver(_:))
        }
        
//        let menu = NSMenu()
//        menu.delegate = self
//        menu.autoenablesItems = false
//
//        menu.addItem(NSMenuItem.separator())
//        menu.addItem(preferenceItem)
//        menu.addItem(aboutItem)
//        menu.addItem(NSMenuItem.separator())
//        menu.addItem(quitMenuItem)
//        statusItem.menu = menu
//        updateRecentAppMenus()
//        updateDeviceMenus()
//
    }
    
    // MARK: Actions
    
    @objc func togglePopver(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    // MARK: Private
    private func showPopover(sender: Any?) {
        guard let button = statusItem.button else {
            return
        }
        log.info("show Popover")
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        guard monitor == nil else {
            return
        }
        monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let weakSelf = self,
                weakSelf.popover.isShown else {
                    return
            }
            weakSelf.closePopover(sender: event)
        }
    }
    
    func closePopover(sender: Any?) {
        log.info("close Popover")
        popover.performClose(sender)
        if let monitor = self.monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
