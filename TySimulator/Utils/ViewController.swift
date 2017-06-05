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
        
        for window in NSApp.windows {
            if window.isVisible {
                _ = NSApplication.toggleDockIcon(showIcon: true)
                return
            }
        }
    }
    
    func ty_viewDidDisappear() {
        ty_viewDidDisappear()
        for window in NSApp.windows {
            if window.isVisible && String(describing: type(of:window)) != "NSStatusBarWindow" {
                return
            }
        }
        _ = NSApplication.toggleDockIcon(showIcon: false)
    }
}
