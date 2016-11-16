//
//  Preferences.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import MASPreferences

struct Preferences {
    static private let sharedPreferencesWindowController: MASPreferencesWindowController = preferencesWindowController()
    
    static func sharedWindowController() -> MASPreferencesWindowController {
        return sharedPreferencesWindowController
    }
    
    private static func preferencesWindowController() -> MASPreferencesWindowController {
        let generalViewController = GeneralPreferencesViewController()
        let preferencesWindow = MASPreferencesWindowController(viewControllers: [generalViewController], title: "Preferences")
        return preferencesWindow!
    }
}
