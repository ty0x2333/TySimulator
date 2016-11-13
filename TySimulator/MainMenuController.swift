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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusItem.image = NSImage(named: "MenuIcon")
        statusItem.menu = makeMenu()
    }
    
    func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        
        menu.addItem(makeQuitItem())
        return menu
    }
    
    func makeQuitItem() -> NSMenuItem {
        let item = NSMenuItem()
        item.title = "Quit TySimulator"
        item.isEnabled = true
//        item.target = self
//        item.action = #Selector(qu)
        return item;
    }
}
