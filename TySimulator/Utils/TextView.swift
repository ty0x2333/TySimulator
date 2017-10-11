//
//  TextView.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/30.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

private var placeHolderKey = 0
extension NSTextView {
    private var placeHolder: NSAttributedString? {
        get {
            return objc_getAssociatedObject(self, &placeHolderKey) as? NSAttributedString
        }
        
        set {
            objc_setAssociatedObject(self, &placeHolderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var placeHolderString: String? {
        set {
            if let string = newValue {
                placeHolder = NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: NSColor.gray])
                needsDisplay = true
            }
        }
        
        get {
            return placeHolder?.string
        }
    }
    
    override open class func initialize() {
        guard self == NSTextView.self else {
            return
        }
        
        let originalBecomeFirstResponder = class_getInstanceMethod(self, #selector(becomeFirstResponder))
        let swizzledBecomeFirstResponder = class_getInstanceMethod(self, #selector(swizzle_becomeFirstResponder))
        method_exchangeImplementations(originalBecomeFirstResponder, swizzledBecomeFirstResponder)
        
        let originalDraw = class_getInstanceMethod(self, #selector(draw(_:)))
        let swizzledDraw = class_getInstanceMethod(self, #selector(swizzle_draw(_:)))
        method_exchangeImplementations(originalDraw, swizzledDraw)
    }
    
    func swizzle_becomeFirstResponder() -> Bool {
        needsDisplay = true
        return swizzle_becomeFirstResponder()
    }
    
    func swizzle_draw(_ dirtyRect: NSRect) {
        swizzle_draw(dirtyRect)
        guard string!.isEmpty else {
            return
        }
        if let placeHolder = placeHolder {
            placeHolder.draw(in: NSRect(x: 5, y: 0, width: bounds.size.width - 2 * 5, height: bounds.size.height))
        }
    }
    
}
