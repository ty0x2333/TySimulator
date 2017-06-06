//
//  Menu.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

extension NSMenuItem {
    class func deviceMenuItems(_ devices: [DeviceModel], _ tagMap: [String: Int]) -> [NSMenuItem] {
        var items: [NSMenuItem] = []
        
        var osInfo: String = ""
        
        devices.forEach {
            if $0.osInfo != osInfo {
                osInfo = $0.osInfo
                if !items.isEmpty {
                    items.append(NSMenuItem.separator())
                }
                items.append(header($0.osInfo))
            }
            let item = deviceMenuItem($0)
            item.tag = tagMap[$0.udid]!
            items.append(item)
        }
        
        return items
    }
    
    class func deviceMenuItem(_ device: DeviceModel) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = device.name
        item.isEnabled = device.isAvailable
        item.state = device.isOpen ? 1 : 0
        item.onStateImage = NSImage(named: "icon-on")
        item.offStateImage = NSImage(named: "icon-off")
        
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        menu.addSection(title: "Applications", items: applicationMenuItems(device.applications))
        menu.addSection(title: "App Groups", items: appGroupMenuItems(device.appGroups))
        menu.addSection(title: "Media", items: mediaMenuItems(device.medias))
        
        item.submenu = menu
        return item
    }

    private class func applicationMenuItems(_ applications: [ApplicationModel]) -> [NSMenuItem] {
        return applications.map {
            let item = menuItem($0.name, target: $0, action: #selector(ApplicationModel.handleMenuItem(_:)))
            item.image = $0.icon
            item.image?.size = NSSize(width: 24, height: 24)
            item.isEnabled = true
            return item
        }
    }
    
    private class func appGroupMenuItems(_ appGroups: [AppGroupModel]) -> [NSMenuItem] {
        return appGroups.map { menuItem($0.bundleIdentifier, target: $0, action: #selector(AppGroupModel.handleMenuItem(_:))) }
    }
    
    private class func mediaMenuItems(_ media: [MediaModel]) -> [NSMenuItem] {
        return media.map { menuItem($0.name, target: $0, action: #selector(MediaModel.handleMenuItem(_:))) }
    }
    
    // MARK: - Helper
    
    fileprivate class func header(_ title: String) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = title
        item.isEnabled = false
        
        return item
    }
    
    private class func menuItem(_ title: String, target: AnyObject, action: Selector?) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = title
        item.isEnabled = true
        item.target = target
        item.action = action
        return item
    }
}

extension NSMenu {
    fileprivate func addSection(title: String, items: [NSMenuItem]) {
        addItem(NSMenuItem.separator())
        addItem(NSMenuItem.header(title))
        items.forEach {
            addItem($0)
        }
    }
}
