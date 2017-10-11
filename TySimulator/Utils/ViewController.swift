//
//  ViewController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/12/3.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

extension NSViewController {
    override open class func initialize() {

        guard self == NSViewController.self else {
            return
        }

        let swizzlingClose = {
            let originalMethod = class_getInstanceMethod(self, #selector(viewDidAppear));
            let swizzledMethod = class_getInstanceMethod(self, #selector(ty_viewDidAppear));

            method_exchangeImplementations(originalMethod, swizzledMethod);
        }

        let swizzlingShow = {
            let originalMethod = class_getInstanceMethod(self, #selector(viewDidDisappear));
            let swizzledMethod = class_getInstanceMethod(self, #selector(ty_viewDidDisappear));

            method_exchangeImplementations(originalMethod, swizzledMethod);
        }

        swizzlingShow()
        swizzlingClose()
    }
    
    func ty_viewDidAppear() {
        ty_viewDidAppear()
        
        guard className != "NSTouchBarViewController" else {
            return
        }
        if NSApp.windows.contains(where: { $0.isVisible }) {
            NSApplication.toggleDockIcon(showIcon: true)
        }
    }
    
    func ty_viewDidDisappear() {
        ty_viewDidDisappear()
        
        guard className != "NSTouchBarViewController" else {
            return
        }
        if NSApp.windows.contains(where: { $0.isVisible && String(describing: type(of:$0)) != "NSStatusBarWindow" }) {
            return
        }
        NSApplication.toggleDockIcon(showIcon: false)
    }
}
