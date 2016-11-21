//
//  Preference.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import MASPreferences
import MASShortcut

class Preference: NSObject {
    static let kUserDefaultsKeyPreferences = "com.tianyiyan.preferences"
    static let kUserDefaultsKeyOnlyAvailableDevices = "onlyAvailableDevices"
    static let kUserDefaultsKeyOnlyHasContentDevices = "onlyHasContentDevices"
    static let kUserDefaultsKeyCommands = "commands"
    private static let sharedPreferencesWindowController: MASPreferencesWindowController = preferencesWindowController()
    private static let sharedPreferences: Preference = preference()
    private var preferences: Dictionary<String, Any>?
    private(set) var commands: [CommandModel]?
    
    static func shared() -> Preference {
        return sharedPreferences
    }
    
    static func sharedWindowController() -> MASPreferencesWindowController {
        return sharedPreferencesWindowController
    }
    
    override init() {
        super.init()
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: [
            Preference.kUserDefaultsKeyPreferences: [
                Preference.kUserDefaultsKeyOnlyAvailableDevices: true,
                Preference.kUserDefaultsKeyOnlyHasContentDevices: false,
                Preference.kUserDefaultsKeyCommands: []
            ]
        ])

        self.preferences = UserDefaults.standard.dictionary(forKey: Preference.kUserDefaultsKeyPreferences)
        self.commands = []
        if let datas = self.preferences?[Preference.kUserDefaultsKeyCommands] as? Array<Dictionary<String, Any>> {
            let transformer = MASDictionaryTransformer()
            for data in datas {
                let command = CommandModel()
                command.name = data["name"]  as! String
                if let shortcut = data["shortcut"] as? Dictionary<String, Any> {
                    command.key = transformer.transformedValue(shortcut) as! MASShortcut?
                }
                command.script = data["script"] as! String
                self.commands?.append(command)
            }
        }
    }
    
    func addCommand(_ command: CommandModel) {
        self.addCommands([command])
    }
    
    func addCommands(_ commands: [CommandModel]) {
        self.commands? += commands
        self.synchronize()
    }
    
    func removeCommand(at: Int) {
        self.commands?.remove(at: at)
        self.synchronize()
    }
    
    func synchronize() {
        let transformer = MASDictionaryTransformer()
        let commandDatas = self.commands?.map { (model) -> Dictionary<String, Any> in
            let shortcut = transformer.reverseTransformedValue(model.key)!
            return ["name": model.name, "script": model.script, "shortcut": shortcut]
        }
        self.preferences?[Preference.kUserDefaultsKeyCommands] = commandDatas
        UserDefaults.standard.set(self.preferences, forKey: Preference.kUserDefaultsKeyPreferences)
        UserDefaults.standard.synchronize()
    }
    
    private class func preference() -> Preference {
        return Preference()
    }
    
    private class func preferencesWindowController() -> MASPreferencesWindowController {
        let generalViewController = GeneralPreferencesViewController()
        let keyBindingViewController = KeyBindingsPreferencesViewController()
        let preferencesWindow = MASPreferencesWindowController(viewControllers: [generalViewController, keyBindingViewController], title: "Preferences")
        preferencesWindow?.window?.level = Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow))
        return preferencesWindow!
    }
    
    static var onlyAvailableDevices: Bool {
        get {
            let preferences: Dictionary<String, Any> = Preference.shared().preferences!
            if let onlyAvailableDevices = preferences[kUserDefaultsKeyOnlyAvailableDevices] {
                return onlyAvailableDevices as! Bool
            } else {
                return true
            }
        }
        
        set {
            var preferences: Dictionary<String, Any> = Preference.shared().preferences!
            preferences[kUserDefaultsKeyOnlyAvailableDevices] = newValue
            UserDefaults.standard.set(preferences, forKey: kUserDefaultsKeyPreferences)
            UserDefaults.standard.synchronize()
            log.verbose("update preferences: \(preferences)")
        }
    }
    
    static var onlyHasContentDevices: Bool {
        get {
            let preferences: Dictionary<String, Any> = Preference.shared().preferences!
            if let onlyAvailableDevices = preferences[kUserDefaultsKeyOnlyHasContentDevices] {
                return onlyAvailableDevices as! Bool
            } else {
                return true
            }
        }
        
        set {
            var preferences: Dictionary<String, Any> = Preference.shared().preferences!
            preferences[kUserDefaultsKeyOnlyHasContentDevices] = newValue
            UserDefaults.standard.set(preferences, forKey: kUserDefaultsKeyPreferences)
            UserDefaults.standard.synchronize()
            log.verbose("update preferences: \(preferences)")
        }
    }
    
}
