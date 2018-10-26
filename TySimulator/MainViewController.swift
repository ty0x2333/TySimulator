//
//  MainViewController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2018/10/15.
//  Copyright © 2018 luckytianyiyan. All rights reserved.
//

import Foundation
import SnapKit

class MainViewController: NSViewController {
    @IBOutlet weak var deviceTableView: NSTableView!
    @IBOutlet weak var infoCollectionView: NSCollectionView!
    @IBOutlet weak var splitView: NSSplitView!
    
    @IBOutlet weak var progressView: NSProgressIndicator!
    @IBOutlet weak var recentView: NSView!
    @IBOutlet weak var recentCollectionView: NSCollectionView!
    
    @IBOutlet weak var emptyView: NSView!
    @IBOutlet var splitBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recentContainerView: NSScrollView!
    
    private static let headerItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "infoSectionHeader")
    private static let appItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "defaultItem")
    private static let recentItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "recentItem")
    private var devices: [DeviceModel] = [] {
        didSet {
            recentCollectionView.reloadData()
            updateRecentView()
        }
    }
    private var recentApplications: [ApplicationModel] = []
    private var selectedDeviceUDID: String?
    
    private var selectedDevice: DeviceModel? {
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
        
        infoCollectionView.register(NSNib(nibNamed: "MainViewController", bundle: nil), forItemWithIdentifier: MainViewController.appItemIdentifier)
        infoCollectionView.register(InfoSectionHeaderView.self, forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader, withIdentifier: MainViewController.headerItemIdentifier)
        infoCollectionView.delegate = self
        infoCollectionView.dataSource = self
        
        recentCollectionView.register(NSNib(nibNamed: "BaseDetailCollectionItem", bundle: nil), forItemWithIdentifier: MainViewController.recentItemIdentifier)
        recentCollectionView.dataSource = self
        recentCollectionView.delegate = self
        
        for subview in splitView.subviews {
            subview.wantsLayer = true
            subview.layer?.cornerRadius = 4.0
            subview.layer?.masksToBounds = true
        }
        
        recentContainerView.wantsLayer = true
        recentContainerView.layer?.cornerRadius = 4.0
        recentContainerView.layer?.masksToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(devicesChangedNotification(sender:)), name: Notification.Name.Device.DidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateRecentApplications), name: Notification.Name.LRUCache.DidRecord, object: nil)
        
        devices = Simulator.shared.devices
        reloadInfos()
        updateRecentApplications()
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
    
    private func reloadInfos() {
        infoCollectionView.reloadData()
        emptyView.isHidden = numberOfSections(in: infoCollectionView) > 0
    }
    
    @objc private func updateRecentApplications() {
        let datas = LRUCache.shared.datas
        guard datas.count > 0 else {
            recentApplications = []
            return
        }
        var apps: [ApplicationModel] = []
        let bootedDevices = Simulator.shared.bootedDevices
        for bundleID in datas {
            for device in bootedDevices {
                if let app = device.application(bundleIdentifier: bundleID) {
                    apps.append(app)
                    break
                }
            }
        }

        guard apps.count > 0 else {
            recentApplications = []
            return
        }

        log.verbose("update recent apps")
        
        var models: [ApplicationModel] = []
        for (idx, app) in apps.enumerated() {
            if idx > 2 {
                break
            }
            models.append(app)
        }
        recentApplications = models
    }
    
    @IBAction func onMenuClick(_ sender: NSButton) {
        guard let menu = (NSApp.delegate as? AppDelegate)?.mainMenuController?.menu,
            let event = NSApp.currentEvent else {
            return
        }
        NSMenu.popUpContextMenu(menu, with: event, for: sender)
    }
    
    // MARK: Notification
    @objc func devicesChangedNotification(sender: Notification) {
        log.verbose("devicesChangedNotification updateDeviceMenus")
        updateDeviceMenus()
        updateRecentApplications()
    }
    
    // MARK: Helper
    
    private func updateRecentView() {
        let isVisible = recentApplications.count > 0
        splitBottomConstraint.isActive = isVisible
        recentView.isHidden = !isVisible
    }
}

extension MainViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let result: AppMenuTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"), owner: self) as! AppMenuTableCellView
        if devices.indices.contains(row) {
            let device = devices[row]
            result.name = device.displayName
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
        reloadInfos()
    }
}

extension MainViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return devices.count
    }
}

extension MainViewController: NSSplitViewDelegate {
    func splitViewWillResizeSubviews(_ notification: Notification) {
        infoCollectionView.collectionViewLayout?.invalidateLayout()
    }
}

extension MainViewController: NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        if collectionView == recentCollectionView {
            return 1
        }
        guard let device = selectedDevice else {
            return 0
        }
        if device.applications.isEmpty, device.appGroups.isEmpty, device.medias.isEmpty {
            return 0
        }
        return 3
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView == infoCollectionView else {
            return recentApplications.count
        }
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
        guard collectionView == infoCollectionView else {
            let item = collectionView.makeItem(withIdentifier: MainViewController.recentItemIdentifier, for: indexPath) as! BaseDetailCollectionItem
            if recentApplications.indices.contains(indexPath.item) {
                let app = recentApplications[indexPath.item]
                if let imageView = item.imageView {
                    imageView.wantsLayer = true
                    imageView.layer?.cornerRadius = 10.0
                    imageView.layer?.masksToBounds = true
                }
                item.icon = app.bundle.appIcon
                item.name = app.bundle.appName
                item.location = app.dataPath
            }
            return item
        }
        let item = collectionView.makeItem(withIdentifier: MainViewController.appItemIdentifier, for: indexPath) as! DetailCollectionItem
        switch indexPath.section {
        case 0:
            if let applications = selectedDevice?.applications, applications.indices.contains(indexPath.item) {
                let app = applications[indexPath.item]
                item.icon = app.bundle.appIcon
                item.name = app.bundle.appName
                item.type = .app
                item.location = app.dataPath
            }
        case 1:
            if let groups = selectedDevice?.appGroups, groups.indices.contains(indexPath.item) {
                let group = groups[indexPath.item]
                item.name = group.bundleIdentifier
                item.type = .group
                item.location = group.location
            }
        case 2:
            if let medias = selectedDevice?.medias, medias.indices.contains(indexPath.item) {
                let media = medias[indexPath.item]
                item.name = media.name
                item.type = .assets
                item.location = media.location
            }
        default:
            break
        }
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        if collectionView == infoCollectionView, kind == NSCollectionView.elementKindSectionHeader {
            let headerView = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: MainViewController.headerItemIdentifier, for: indexPath)
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
            (headerView as? InfoSectionHeaderView)?.title = text
            return headerView
        }
        return NSView()
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return collectionView == infoCollectionView ? CGSize(width: collectionView.bounds.width, height: InfoSectionHeaderView.defaultHeight) : .zero
    }
}

extension MainViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return collectionView == infoCollectionView ? CGSize(width: collectionView.bounds.width, height: 49) : CGSize(width: 63.0, height: 65.0)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        
        var location: URL?
        if collectionView == infoCollectionView {
            location = detailItemLocation(indexPath: indexPath)
        } else if recentApplications.indices.contains(indexPath.item) {
            location = recentApplications[indexPath.item].dataPath
        }
        
        if let loc = location {
            DispatchQueue.main.async {
                NSWorkspace.shared.open(loc)
            }
        }
        (NSApp.delegate as? AppDelegate)?.mainMenuController?.closePopover(sender: nil)
    }
    
    private func detailItemLocation(indexPath: IndexPath) -> URL? {
        switch indexPath.section {
        case 0:
            if let applications = selectedDevice?.applications, applications.indices.contains(indexPath.item) {
                let app = applications[indexPath.item]
                LRUCache.shared.record(app: app.bundle.bundleID)
                return app.dataPath
            }
        case 1:
            if let groups = selectedDevice?.appGroups, groups.indices.contains(indexPath.item) {
                return groups[indexPath.item].location
            }
        case 2:
            if let medias = selectedDevice?.medias, medias.indices.contains(indexPath.item) {
                let media = medias[indexPath.item]
                return media.location
            }
        default:
            break
        }
        return nil
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
            NSColor.selectedControlColor.set()
            dirtyRect.fill()
        }
    }
}

class BaseDetailCollectionItem: NSCollectionViewItem {
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
    
    var location: URL?
}

class DetailCollectionItem: BaseDetailCollectionItem {
    enum ItemType {
        case app
        case assets
        case group
    }
    var directoryWatcher: DirectoryWatcher?
    @IBOutlet private weak var sizeTextField: NSTextField!
    
    var type: ItemType = .app {
        didSet {
            if type == .app {
                imageView?.layer?.cornerRadius = 21.0
            } else {
                icon = NSImage(named: "finder")
                imageView?.layer?.cornerRadius = 0
            }
        }
    }
    
   override var location: URL? {
        didSet {
            directoryWatcher?.invalidate()
            guard let url = location?.appendingPathComponent("Documents", isDirectory: true) else {
                return
            }
            directoryWatcher = DirectoryWatcher.watchFolder(path: url.path, didChange: { [weak self] in
                log.verbose("\(url) did change")
                self?.updateSizeText()
            })
            updateSizeText()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView?.wantsLayer = true
        imageView?.layer?.cornerRadius = 21.0
        imageView?.layer?.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        location = nil
        directoryWatcher = nil
        icon = nil
        name = nil
    }
    
    private func updateSizeText() {
        guard let url = location,
            let numerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [], errorHandler: nil) else {
            sizeTextField.isHidden = true
            return
        }
        var total: Int64 = 0
        for object in numerator {
            var fileSizeResource: AnyObject?
            guard let fileURL = object as? NSURL else {
                continue
            }
            try? fileURL.getResourceValue(&fileSizeResource, forKey: .fileSizeKey)
            guard let fileSize = fileSizeResource as? NSNumber else {
                continue
            }
            total += fileSize.int64Value
        }
        sizeTextField.isHidden = false
        sizeTextField.stringValue = ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }
}

class InfoSectionHeaderView: NSView {
    static let defaultHeight: CGFloat = 40.0
    private var textField: NSTextField = NSTextField()
    var title: String? {
        set {
            textField.stringValue = newValue ?? ""
        }
        get {
            return textField.stringValue
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        textField.isBezeled = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.font = NSFont.boldSystemFont(ofSize: 13.0)
        addSubview(textField)
        
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16.0)
            make.centerY.right.equalToSuperview()
        }
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.placeholderTextColor.setFill()
        NSRect(x: 16.0, y: 8.0, width: bounds.width - 16.0, height: 0.5).fill()
    }
}
