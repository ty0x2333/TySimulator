//
//  MainMenuController.swift
//  TySimulator
//
//  Created by ty0x2333 on 2016/11/13.
//  Copyright © 2016年 ty0x2333. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover: NSPopover = NSPopover()
    let quitMenuItem: NSMenuItem = NSMenuItem(title: NSLocalizedString("menu.quit", comment: "menu"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    let aboutItem: NSMenuItem = NSMenuItem(title: NSLocalizedString("menu.about", comment: "menu"), action: #selector(NSApplication.showAboutWindow), keyEquivalent: "")
    let preferenceItem: NSMenuItem = NSMenuItem(title: NSLocalizedString("menu.preference", comment: "menu"), action: #selector(NSApplication.showPreferencesWindow), keyEquivalent: ",")
    lazy var menu: NSMenu = {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(preferenceItem)
        menu.addItem(aboutItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitMenuItem)
        return menu
    }()
    
    var monitor: Any?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        popover.contentViewController = MainViewController(nibName: "MainViewController", bundle: nil)
        
        if let button = statusItem.button {
            button.image = NSImage(named: "MenuIcon")
            button.target = self
            button.action = #selector(MainMenuController.togglePopver(_:))
        }
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
