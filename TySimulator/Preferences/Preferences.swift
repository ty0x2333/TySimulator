//
//  Preferences.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import MASPreferences
import MASShortcut

class Preferences {
    static let kUserDefaultsKeyPreferences = "com.tianyiyan.preferences"
    static let kUserDefaultsKeyOnlyAvailableDevices = "onlyAvailableDevices"
    static let kUserDefaultsKeyOnlyHasContentDevices = "onlyHasContentDevices"
    static let kUserDefaultsKeyCommands = "commands"
    private static let sharedPreferencesWindowController: MASPreferencesWindowController = preferencesWindowController()
    
    static func sharedWindowController() -> MASPreferencesWindowController {
        return sharedPreferencesWindowController
    }
    
    private class func preferencesWindowController() -> MASPreferencesWindowController {
        let generalViewController = GeneralPreferencesViewController()
        let keyBindingViewController = KeyBindingsPreferencesViewController()
        let preferencesWindow = MASPreferencesWindowController(viewControllers: [generalViewController, keyBindingViewController], title: "Preferences")
        preferencesWindow?.window?.level = Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow))
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: [
            kUserDefaultsKeyPreferences: [
                kUserDefaultsKeyOnlyAvailableDevices: true,
                kUserDefaultsKeyOnlyHasContentDevices: false,
                kUserDefaultsKeyCommands: []
            ]
        ])
        return preferencesWindow!
    }
    
    static var commands: [CommandModel] {
        get {
            let preferences: Dictionary<String, Any> = Preferences.preferences()
            if let datas = preferences[kUserDefaultsKeyCommands] as? Array<Dictionary<String, Any>> {
                var result = [CommandModel]()
                let transformer = MASDictionaryTransformer()
                for data in datas {
                    let command = CommandModel()
                    command.name = data["name"]  as! String
                    if let shortcut = data["shortcut"] as? Dictionary<String, Any> {
                        command.key = transformer.transformedValue(shortcut) as! MASShortcut?
                    }
                    command.script = data["script"] as! String
                    result.append(command)
                }
                return result
            } else {
                return []
            }
        }
        
        set {
            var preferences: Dictionary<String, Any> = Preferences.preferences()
            let transformer = MASDictionaryTransformer()
            let commands = newValue.map { (model) -> Dictionary<String, Any> in
                let shortcut = transformer.reverseTransformedValue(model.key)!
                return ["name": model.name, "script": model.script, "shortcut": shortcut]
            }
            preferences[kUserDefaultsKeyCommands] = commands
            UserDefaults.standard.set(preferences, forKey: kUserDefaultsKeyPreferences)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var onlyAvailableDevices: Bool {
        get {
            let preferences: Dictionary<String, Any> = Preferences.preferences()
            if let onlyAvailableDevices = preferences[kUserDefaultsKeyOnlyAvailableDevices] {
                return onlyAvailableDevices as! Bool
            } else {
                return true
            }
        }
        
        set {
            var preferences: Dictionary<String, Any> = Preferences.preferences()
            preferences[kUserDefaultsKeyOnlyAvailableDevices] = newValue
            UserDefaults.standard.set(preferences, forKey: kUserDefaultsKeyPreferences)
            UserDefaults.standard.synchronize()
            log.verbose("update preferences: \(preferences)")
        }
    }
    
    static var onlyHasContentDevices: Bool {
        get {
            let preferences: Dictionary<String, Any> = Preferences.preferences()
            if let onlyAvailableDevices = preferences[kUserDefaultsKeyOnlyHasContentDevices] {
                return onlyAvailableDevices as! Bool
            } else {
                return true
            }
        }
        
        set {
            var preferences: Dictionary<String, Any> = Preferences.preferences()
            preferences[kUserDefaultsKeyOnlyHasContentDevices] = newValue
            UserDefaults.standard.set(preferences, forKey: kUserDefaultsKeyPreferences)
            UserDefaults.standard.synchronize()
            log.verbose("update preferences: \(preferences)")
        }
    }
    
    static func preferences() -> Dictionary<String, Any> {
        if let preferences = UserDefaults.standard.dictionary(forKey: kUserDefaultsKeyPreferences) {
            return preferences
        } else {
            return Dictionary()
        }
    }
    
}
