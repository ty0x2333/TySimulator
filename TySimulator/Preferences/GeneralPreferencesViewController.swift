//
//  GeneralPreferencesViewController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import MASPreferences

class GeneralPreferencesViewController: NSViewController, MASPreferencesViewController {
    
    // MARK: MASPreferencesViewController
    override var identifier: String? {
        get { return "GeneralPreferences" }
        set { super.identifier = newValue }
    }
    
    var toolbarItemImage: NSImage! = NSImage(named: NSImageNamePreferencesGeneral)

    var toolbarItemLabel: String! = "General"
}
