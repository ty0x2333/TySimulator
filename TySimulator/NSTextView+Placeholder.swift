//
//  NSTextView+Placeholder.swift
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
                self.placeHolder = NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: NSColor.gray])
                self.needsDisplay = true
            }
        }
        
        get {
            return self.placeHolder?.string
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
        self.needsDisplay = true
        return self.swizzle_becomeFirstResponder()
    }
    
    func swizzle_draw(_ dirtyRect: NSRect) {
        self.swizzle_draw(dirtyRect)
        guard self.string!.isEmpty else {
            return
        }
        if let placeHolder = self.placeHolder {
            placeHolder.draw(at: NSMakePoint(5, 0))
        }
    }
    
}
