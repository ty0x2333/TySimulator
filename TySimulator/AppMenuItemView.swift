//
//  AppMenuItemView.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2017/7/18.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation

class AppMenuItemView: NSView {
    
    enum Style: Int {
        case `default`
        case detail
    }
    
    @IBOutlet weak var appNameLabel: NSTextField!
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var sizeLabel: NSTextField!
    
    @IBOutlet weak var appNameCenterConstraint: NSLayoutConstraint!
    private var trackingArea: NSTrackingArea?
    
    var highlight: Bool = false
    var style: AppMenuItemView.Style = .`default` {
        didSet {
            if style == .`default` {
                sizeLabel.isHidden = true
                appNameCenterConstraint.isActive = true
                directoryWatcher?.invalidate()
            } else {
                sizeLabel.isHidden = false
                appNameCenterConstraint.isActive = false
                updateWatcher()
            }
        }
    }
    
    var icon: NSImage? {
        set {
            newValue?.isTemplate = false
            iconImageView?.image = newValue ?? NSImage(named: "tmp-logo")
        }
        
        get {
            return iconImageView?.image
        }
    }
    
    var appName: String {
        set {
            appNameLabel?.stringValue = newValue
        }
        
        get {
            return appNameLabel?.stringValue ?? ""
        }
    }
    
    var bundleIdentifier: String = ""
    var directoryWatcher: DirectoryWatcher?
    var location: URL? {
        didSet {
            guard style == .detail else {
                return
            }
            updateSize()
            updateWatcher()
        }
    }
    
    func updateSize() {
        var total: Int64 = 0
        if let url = location?.appendingPathComponent("Documents", isDirectory: true), let numerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [], errorHandler: nil) {
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
        }
        sizeLabel.stringValue = ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    class func loadFromNib() -> AppMenuItemView {
        var objects: NSArray?
        Bundle.main.loadNibNamed("AppMenuItemView", owner: nil, topLevelObjects: &objects)
        return objects!.first(where: { $0 is AppMenuItemView }) as! AppMenuItemView
    }
    
    private func commonInit() {
        iconImageView?.wantsLayer = true
        iconImageView?.layer?.cornerRadius = 4.0
        iconImageView?.layer?.masksToBounds = true
        appNameCenterConstraint.isActive = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if highlight {
            NSColor.selectedMenuItemColor.set()
            dirtyRect.fill()
        }
    }
    
    override func updateTrackingAreas() {
        if let trackingArea = self.trackingArea {
            removeTrackingArea(trackingArea)
        }
        
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        let trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
    // MARK: Event
    
    override func mouseUp(with event: NSEvent) {
        if let menu = enclosingMenuItem?.menu {
            menu.cancelTracking()
        }
        highlight = false
        needsDisplay = true
        
        guard let location = self.location else {
            return
        }
        if !bundleIdentifier.isEmpty {
            LRUCache.shared.record(app: bundleIdentifier)
        }
        NSWorkspace.shared.open(location)
    }
    
    override func mouseEntered(with event: NSEvent) {
        highlight = true
        needsDisplay = true
    }
    
    override func mouseExited(with event: NSEvent) {
        highlight = false
        needsDisplay = true
    }
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    // MARK: Helper
    
    func updateWatcher() {
        guard let url = location?.appendingPathComponent("Documents", isDirectory: true) else {
            return
        }
        directoryWatcher?.invalidate()
        directoryWatcher = DirectoryWatcher.watchFolder(path: url.path, didChange: { [weak self] in
            log.verbose("\(url) did change")
            self?.updateSize()
        })
    }
}
