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
        
        for device in devices {
            if device.osInfo != osInfo {
                osInfo = device.osInfo
                if !items.isEmpty {
                    items.append(NSMenuItem.separator())
                }
                items.append(sectionMenuItem(device.osInfo))
            }
            let item = deviceMenuItem(device)
            if let tag = tagMap[device.udid] {
                item.tag = tag
            }
            items.append(item)
        }
        return items
    }
    
    class func deviceMenuItem(_ device: DeviceModel) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = device.name
        item.isEnabled = device.isAvailable
        item.state = NSControl.StateValue(rawValue: device.isOpen ? 1 : 0)
        item.onStateImage = NSImage(named: "icon-on")
        item.offStateImage = NSImage(named: "icon-off")

        let menu = NSMenu()
        menu.autoenablesItems = false

        menu.addSection(title: NSLocalizedString("menu.application", comment: "menu"), items: applicationMenuItems(device.applications, style: .detail))
        menu.addSection(title: NSLocalizedString("menu.app.group", comment: "menu"), items: appGroupMenuItems(device.appGroups))
        menu.addSection(title: NSLocalizedString("menu.media", comment: "menu"), items: mediaMenuItems(device.medias))
        
        item.submenu = menu
        return item
    }

    class func applicationMenuItems(_ applications: [ApplicationModel], style: AppMenuItemView.Style = .`default`) -> [NSMenuItem] {
        return applications.map {
            let view = AppMenuItemView.loadFromNib()
            view.style = style
            view.icon = $0.bundle.appIcon
            view.appName = $0.bundle.appName
            view.location = $0.dataPath
            let item = NSMenuItem()
            item.view = view
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
    
    class func sectionMenuItem(_ title: String) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = title
        item.isEnabled = false
        
        return item
    }
    
    // MARK: - Helper
    
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
    @discardableResult
    func addSection(title: String, items: [NSMenuItem]) -> [NSMenuItem] {
        var added: [NSMenuItem] = [NSMenuItem.separator(), NSMenuItem.sectionMenuItem(title)]
        added.append(contentsOf: items)
        addItems(added)
        return added
    }
    
    func addItems(_ items: [NSMenuItem]) {
        for item in items {
            addItem(item)
        }
    }
    
    func removeItems(_ items: [NSMenuItem]) {
        for item in items {
            if self.items.contains(item) {
                removeItem(item)
            }
        }
    }
}
