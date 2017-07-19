//
//  AppMenuItemView.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2017/7/18.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation

class AppMenuItemView: NSView {
    
    weak var iconImageView: NSImageView?
    weak var appNameLabel: NSTextField?
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    func commonInit() {
        iconImageView = subviews.first(where: { $0 is NSImageView }) as? NSImageView
        appNameLabel = subviews.first(where: { $0 is NSTextField }) as? NSTextField
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
    
    override func mouseUp(with event: NSEvent) {
        if let menu = enclosingMenuItem?.menu {
            menu.cancelTracking()
        }
        highlight = false
        needsDisplay = true
    }
    
    override func mouseEntered(with event: NSEvent) {
        highlight = true
        needsDisplay = true
    }
    
    override func mouseExited(with event: NSEvent) {
        highlight = false
        needsDisplay = true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
}
