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
        guard let menuItem = enclosingMenuItem, menuItem.isHighlighted else {
            super.draw(dirtyRect)
            return
        }
        NSColor.selectedMenuItemColor.set()
        NSRectFill(dirtyRect)
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let menuItem = enclosingMenuItem, let menu = menuItem.menu else {
            return
        }
        menu.cancelTracking()
        menu.performActionForItem(at: menu.index(of: menuItem))
    }
}
