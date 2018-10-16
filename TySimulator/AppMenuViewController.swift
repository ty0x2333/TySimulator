//
//  AppMenuViewController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2018/10/15.
//  Copyright © 2018 luckytianyiyan. All rights reserved.
//

import Foundation

class AppMenuViewController: NSViewController {
    @IBOutlet weak var deviceTableView: NSTableView!
    @IBOutlet weak var infoCollectionView: NSCollectionView!
    @IBOutlet weak var splitView: NSSplitView!
    
    @IBOutlet weak var progressView: NSProgressIndicator!
    static let headerItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "infoSectionHeader")
    var devices: [DeviceModel] = []
    var recentItems: [NSMenuItem] = []
    var selectedDeviceUDID: String?
    
    var selectedDevice: DeviceModel? {
        guard let udid = selectedDeviceUDID else {
            return nil
        }
        return devices.first(where: { $0.udid == udid })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splitView.delegate = self
        deviceTableView.selectionHighlightStyle = .none
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        infoCollectionView.register(NSNib(nibNamed: "AppMenuViewController", bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultItem"))
        infoCollectionView.register(NSNib(nibNamed: "InfoSectionHeaderView", bundle: nil), forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader, withIdentifier: AppMenuViewController.headerItemIdentifier)
        
        infoCollectionView.delegate = self
        infoCollectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(devicesChangedNotification(sender:)), name: Notification.Name.Device.DidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(recentAppsDidRecordNotification), name: Notification.Name.LRUCache.DidRecord, object: nil)
        
        devices = Simulator.shared.devices
        infoCollectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        progressView.startAnimation(nil)
        DispatchQueue.global().async {
            Simulator.shared.updateDeivces()
            DispatchQueue.main.async {
                self.progressView.stopAnimation(nil)
            }
        }
    }
    
    private func updateDeviceMenus() {
        log.verbose("update devices")
        
        devices = Simulator.shared.devices
        log.info("load devices: \(devices.count)")
        
        deviceTableView.reloadData()
    }
    
    private func updateRecentAppMenus() {
//        guard let menu = statusItem.menu else {
//            return
//        }
//        menu.removeItems(recentItems)
//        recentItems.removeAll()
//        let datas = LRUCache.shared.datas
//        guard datas.count > 0 else {
//            return
//        }
//        var apps: [ApplicationModel] = []
//        let bootedDevices = Simulator.shared.bootedDevices
//        for bundleID in datas {
//            for device in bootedDevices {
//                if let app = device.application(bundleIdentifier: bundleID) {
//                    apps.append(app)
//                    break
//                }
//            }
//        }
//
//        guard apps.count > 0 else {
//            return
//        }
//
//        log.verbose("update recent apps")
//        let titleItem = NSMenuItem.sectionMenuItem(NSLocalizedString("menu.recent", comment: "menu"))
//
//        var models: [ApplicationModel] = []
//        for (idx, app) in apps.enumerated() {
//            if idx > 2 {
//                break
//            }
//            models.append(app)
//        }
//
//        let appItems = NSMenuItem.applicationMenuItems(models, style: .detail)
//        for menuItem in appItems.reversed() {
//            menu.insertItem(menuItem, at: 0)
//        }
//        menu.insertItem(titleItem, at: 0)
//        recentItems = [titleItem] + appItems
    }
    
    // MARK: Notification
    @objc func devicesChangedNotification(sender: Notification) {
        log.verbose("devicesChangedNotification updateDeviceMenus")
        self.updateDeviceMenus()
    }
    
    @objc func recentAppsDidRecordNotification() {
        updateRecentAppMenus()
    }
}

extension AppMenuViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result: AppMenuTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! AppMenuTableCellView
        if devices.indices.contains(row) {
            let device = devices[row]
            result.name = device.name
            result.isAvailable = device.isOpen
            result.isHighlight = device.udid == selectedDeviceUDID
        }
        return result
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if devices.indices.contains(deviceTableView.selectedRow) {
            selectedDeviceUDID = devices[deviceTableView.selectedRow].udid
        }
        deviceTableView.deselectAll(nil)
        deviceTableView.reloadData()
        infoCollectionView.reloadData()
    }
}

extension AppMenuViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return devices.count
    }
}

extension AppMenuViewController: NSSplitViewDelegate {
    func splitViewWillResizeSubviews(_ notification: Notification) {
        infoCollectionView.collectionViewLayout?.invalidateLayout()
    }
}

extension AppMenuViewController: NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let device = selectedDevice else {
            return 0
        }
        switch section {
        case 0:
            return device.applications.count
        case 1:
            return device.appGroups.count
        case 2:
            return device.medias.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultItem"), for: indexPath) as! ApplicationCollectionItem
        switch indexPath.section {
        case 0:
            if let applications = selectedDevice?.applications, applications.indices.contains(indexPath.item) {
                let app = applications[indexPath.item]
                item.icon = app.bundle.appIcon
                item.name = app.bundle.appName
            }
        case 1:
            if let groups = selectedDevice?.appGroups, groups.indices.contains(indexPath.item) {
                let group = groups[indexPath.item]
                item.name = group.bundleIdentifier
                item.icon = NSImage(named: "finder")
            }
        case 2:
            if let medias = selectedDevice?.medias, medias.indices.contains(indexPath.item) {
                let media = medias[indexPath.item]
                item.name = media.name
                item.icon = NSImage(named: "finder")
            }
        default:
            break
        }
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        if kind == NSCollectionView.elementKindSectionHeader {
            let headerView = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: AppMenuViewController.headerItemIdentifier, for: indexPath)
            var text = ""
            switch indexPath.section {
            case 0:
                text = NSLocalizedString("menu.application", comment: "menu")
            case 1:
                text = NSLocalizedString("menu.app.group", comment: "menu")
            case 2:
                text = NSLocalizedString("menu.media", comment: "menu")
            default:
                break
            }
            (headerView as? InfoSectionHeaderView)?.textField.stringValue = text
            return headerView
        }
        return NSView()
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return CGSize(width: collectionView.bounds.width, height: 20)
    }
}

extension AppMenuViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return CGSize(width: collectionView.bounds.width, height: 49)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        switch indexPath.section {
        case 0:
            if let applications = selectedDevice?.applications, applications.indices.contains(indexPath.item) {
                let app = applications[indexPath.item]
                LRUCache.shared.record(app: app.bundle.bundleID)
                NSWorkspace.shared.open(app.dataPath)
            }
        case 1:
            if let groups = selectedDevice?.appGroups, groups.indices.contains(indexPath.item), let location = groups[indexPath.item].location {
                NSWorkspace.shared.open(location)
            }
        case 2:
            if let medias = selectedDevice?.medias, medias.indices.contains(indexPath.item) {
                let media = medias[indexPath.item]
                NSWorkspace.shared.open(media.location)
            }
        default:
            break
        }
        
    }
}

class AppMenuTableCellView: NSTableCellView {
    var name: String? {
        set {
            textField?.stringValue = newValue ?? ""
        }
        get {
            return textField?.stringValue
        }
    }
    var isAvailable: Bool = false {
        didSet {
            imageView?.image = isAvailable ? NSImage(named: "icon-on") : NSImage(named: "icon-off")
        }
    }
    
    var isHighlight: Bool = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isAvailable = false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if isHighlight {
            NSColor.selectedMenuItemColor.set()
            dirtyRect.fill()
        }
    }
}

class ApplicationCollectionItem: NSCollectionViewItem {
    var icon: NSImage? {
        set {
            newValue?.isTemplate = false
            imageView?.image = newValue ?? NSImage(named: "tmp-logo")
        }
        get {
            return imageView?.image
        }
    }
    var name: String? {
        set {
            textField?.stringValue = newValue ?? ""
        }
        get {
            return textField?.stringValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView?.wantsLayer = true
        imageView?.layer?.cornerRadius = 4.0
        imageView?.layer?.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon = nil
        name = nil
    }
}

class InfoSectionHeaderView: NSView {
    @IBOutlet weak var textField: NSTextField!
    var title: String? {
        set {
            textField?.stringValue = newValue ?? ""
        }
        get {
            return textField?.stringValue
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title = nil
    }
}
