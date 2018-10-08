//
//  Preference.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults
import MASPreferences
import MASShortcut

extension UserDefaults {
    subscript(key: DefaultsKey<[[String: Any]]>) -> [[String: Any]] {
        get { return unarchive(key) ?? [] }
        set { archive(key, newValue) }
    }
}

extension DefaultsKeys {
    static let preferences = DefaultsKey<[String: Any]?>("com.tianyiyan.preferences")
    static let onlyAvailableDevices = DefaultsKey<Bool?>("onlyAvailableDevices")
    static let onlyHasContentDevices = DefaultsKey<Bool>("onlyHasContentDevices")
    static let commands = DefaultsKey<[[String: Any]]>("commands")
}

class Preference: NSObject {
    static let sharedWindowController: MASPreferencesWindowController = preferencesWindowController()
    static let shared: Preference = Preference()
    private(set) var commands: [CommandModel] = []
    @objc dynamic var onlyAvailableDevices: Bool {
        didSet {
            Defaults[.onlyAvailableDevices] = onlyAvailableDevices
        }
    }
    @objc dynamic var onlyHasContentDevices: Bool {
        didSet {
            Defaults[.onlyHasContentDevices] = onlyHasContentDevices
        }
    }
    
    override init() {
        
        // init commands
        commands = []
        let transformer = CommandTransformer()
        for data in Defaults[.commands] {
            if let command = transformer.transformedValue(data) as? CommandModel {
                MASShortcutMonitor.shared().register(command: command)
                commands.append(command)
            }
        }
        
        // init switchs
        onlyAvailableDevices = Defaults[.onlyAvailableDevices] ?? true
        onlyHasContentDevices = Defaults[.onlyHasContentDevices]
        
        super.init()
    }
    
    func append(_ command: CommandModel) {
        append(commands: [command])
    }
    
    func append(commands: [CommandModel]) {
        self.commands.append(contentsOf: commands)
        synchronize()
    }
    
    func remove(at index: Int) {
        commands.remove(at: index)
        synchronize()
    }
    
    func setCommand(id: String, command: CommandModel) {
        if let idx = commands.index(where: { $0.id == id }) {
            commands[idx] = command
            synchronize()
        }
    }
    
    func synchronize() {
        let transformer = CommandTransformer()
        Defaults[.commands] = commands.map { transformer.reverseTransformedValue($0) as! [String: Any] }
        UserDefaults.standard.synchronize()
    }
    
    private class func preferencesWindowController() -> MASPreferencesWindowController {
        let generalViewController = GeneralPreferencesViewController()
        let keyBindingViewController = KeyBindingsPreferencesViewController()
        let preferencesWindow = MASPreferencesWindowController(viewControllers: [generalViewController, keyBindingViewController], title: NSLocalizedString("preference.title", comment: "preference"))
        preferencesWindow.window?.level = .floating
        return preferencesWindow
    }
    
}
