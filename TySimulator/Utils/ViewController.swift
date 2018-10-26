//
//  ViewController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/12/3.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

extension NSViewController {
    static func awake() {
        let swizzlingClosure: () = {
            NSViewController.swizzleViewDidAppear
            NSViewController.swizzleViewDidDisappear
        }()
        
        swizzlingClosure
    }
    
    private static let swizzleViewDidAppear: Void = {
        let original = #selector(NSViewController.viewDidAppear)
        let replacement = #selector(NSViewController.ty_viewDidAppear)
        swizzleFunction(original: original, replacement: replacement)
    }()
    
    private static let swizzleViewDidDisappear: Void = {
        let original = #selector(NSViewController.viewDidDisappear)
        let replacement = #selector(NSViewController.ty_viewDidDisappear)
        swizzleFunction(original: original, replacement: replacement)
    }()
    
    private class func swizzleFunction(original: Selector, replacement: Selector) {
        guard let originalMethod: Method = class_getInstanceMethod(NSViewController.self, original),
            let replacementMethod: Method = class_getInstanceMethod(NSViewController.self, replacement) else {
            return
        }
        
        let originalImplementation: IMP = method_getImplementation(originalMethod)
        let originalArgTypes = method_getTypeEncoding(originalMethod)
        
        let replacementImplementation: IMP = method_getImplementation(replacementMethod)
        let replacementArgTypes = method_getTypeEncoding(replacementMethod)
        
        if class_addMethod(NSViewController.self, original, replacementImplementation, replacementArgTypes) {
            class_replaceMethod(NSViewController.self, replacement, originalImplementation, originalArgTypes)
        } else {
            method_exchangeImplementations(originalMethod, replacementMethod)
        }
    }
    
    @objc func ty_viewDidAppear() {
        ty_viewDidAppear()
        
        guard className != "NSTouchBarViewController" else {
            return
        }
        if NSApp.windows.contains(where: { $0.isVisible }) {
            NSApplication.toggleDockIcon(showIcon: true)
        }
    }
    
    @objc func ty_viewDidDisappear() {
        ty_viewDidDisappear()
        
        guard className != "NSTouchBarViewController" else {
            return
        }
        if NSApp.windows.contains(where: { $0.isVisible && String(describing: type(of: $0)) != "NSStatusBarWindow" }) {
            return
        }
        NSApplication.toggleDockIcon(showIcon: false)
    }
}
