//
//  AppMenuItemView.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2017/7/18.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation

class AppMenuItemView: NSView {
    
    
    @IBOutlet weak var appNameLabel: NSTextField!
    @IBOutlet weak var iconImageView: NSImageView!
    
    private var trackingArea: NSTrackingArea?
    
    var highlight: Bool = false
    
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
    var location: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    class func loadFromNib() -> AppMenuItemView {
        var objects: NSArray = []
        Bundle.main.loadNibNamed("AppMenuItemView", owner: nil, topLevelObjects: &objects)
        return objects.first(where: { $0 is AppMenuItemView }) as! AppMenuItemView
    }
    
    private func commonInit() {
        iconImageView?.wantsLayer = true
        iconImageView?.layer?.cornerRadius = 4.0
        iconImageView?.layer?.masksToBounds = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if highlight {
            NSColor.selectedMenuItemColor.set()
            NSRectFill(dirtyRect)
        }
    }
    
    override func updateTrackingAreas() {
        if let trackingArea = self.trackingArea {
            removeTrackingArea(trackingArea)
        }
        
        let options: NSTrackingAreaOptions = [.mouseEnteredAndExited, .activeAlways]
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
        NSWorkspace.shared().open(location)
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
}
