//
//  NSMenu+TySimulator.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

extension NSMenuItem {
    static func deviceMenuItems(_ devices: [DeviceModel], _ tagMap: Dictionary<String, Int>) -> [NSMenuItem] {
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
    
    static func deviceMenuItem(_ device: DeviceModel) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = device.name
        item.isEnabled = device.isAvailable
        item.state = device.isOpen ? 1 : 0
        item.onStateImage = NSImage(named: "icon-on")
        item.offStateImage = NSImage(named: "icon-off")
        
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        let applications = applicationMenuItems(device.applications)
        if !applications.isEmpty {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem.header("Applications"))
            applications.forEach {
                menu.addItem($0)
            }
        }
        
        let appGroups = appGroupMenuItems(device.appGroups)
        if !appGroups.isEmpty {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem.header("App Groups"))
            appGroups.forEach {
                menu.addItem($0)
            }
        }
        
        let medias = mediaMenuItems(device.medias)
        if !medias.isEmpty {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem.header("Media"))
            medias.forEach {
                menu.addItem($0)
            }
        }
        
        item.submenu = menu
        return item
    }

    private static func applicationMenuItems(_ applications: [ApplicationModel]) -> [NSMenuItem] {
        return applications.map {
            let item = NSMenuItem()
            item.title = $0.name
            item.isEnabled = true
            item.target = $0
            item.action = #selector(ApplicationModel.handleMenuItem(_:))
            return item
        }
    }
    
    private static func appGroupMenuItems(_ appGroups: [AppGroupModel]) -> [NSMenuItem] {
        return appGroups.map {
            let item = NSMenuItem()
            item.title = $0.bundleIdentifier
            item.isEnabled = true
            item.target = $0
            item.action = #selector(AppGroupModel.handleMenuItem(_:))
            
            return item
        }
    }
    
    private static func mediaMenuItems(_ media: [MediaModel]) -> [NSMenuItem] {
        return media.map {
            let item = NSMenuItem()
            item.title = $0.name
            item.isEnabled = true
            item.target = $0
            item.action = #selector(MediaModel.handleMenuItem(_:))
            
            return item
        }
    }
    
    // MARK: - Helper
    private static func header(_ title: String) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = title
        item.isEnabled = false
        
        return item
    }
}
