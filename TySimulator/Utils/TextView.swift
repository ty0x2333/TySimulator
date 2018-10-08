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
    static func awake() {
        let swizzlingClosure: () = {
            NSTextView.swizzleBecomeFirstResponder
            NSTextView.swizzleDraw
        }()
        
        swizzlingClosure
    }
    
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
                placeHolder = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: NSColor.gray])
                needsDisplay = true
            }
        }
        
        get {
            return placeHolder?.string
        }
    }
    
    private static let swizzleBecomeFirstResponder: Void = {
        let original = #selector(NSTextView.becomeFirstResponder)
        let replacement = #selector(NSTextView.swizzle_becomeFirstResponder)
        swizzleFunction(original: original, replacement: replacement)
    }()
    
    private static let swizzleDraw: Void = {
        let original = #selector(NSTextView.draw(_:))
        let replacement = #selector(NSTextView.swizzle_draw(_:))
        swizzleFunction(original: original, replacement: replacement)
    }()
    
    private class func swizzleFunction(original: Selector, replacement: Selector) {
        let originalMethod: Method = class_getInstanceMethod(NSTextView.self, original)!
        let originalImplementation: IMP = method_getImplementation(originalMethod)
        let originalArgTypes = method_getTypeEncoding(originalMethod)
        
        let replacementMethod: Method = class_getInstanceMethod(NSTextView.self, replacement)!
        let replacementImplementation: IMP = method_getImplementation(replacementMethod)
        let replacementArgTypes = method_getTypeEncoding(replacementMethod)
        
        if class_addMethod(NSTextView.self, original, replacementImplementation, replacementArgTypes) {
            class_replaceMethod(NSTextView.self, replacement, originalImplementation, originalArgTypes)
        } else {
            method_exchangeImplementations(originalMethod, replacementMethod)
        }
    }
    
    @objc func swizzle_becomeFirstResponder() -> Bool {
        needsDisplay = true
        return swizzle_becomeFirstResponder()
    }
    
    @objc func swizzle_draw(_ dirtyRect: NSRect) {
        swizzle_draw(dirtyRect)
        guard string.isEmpty else {
            return
        }
        if let placeHolder = placeHolder {
            placeHolder.draw(in: NSRect(x: 5, y: 0, width: bounds.size.width - 2 * 5, height: bounds.size.height))
        }
    }
    
}
