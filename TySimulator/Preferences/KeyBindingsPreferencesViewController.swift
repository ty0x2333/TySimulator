//
//  KeyBindingsPreferencesViewController.swift
//  TySimulator
//
//  Created by yinhun on 16/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import MASPreferences

class KeyBindingsPreferencesViewController: NSViewController, MASPreferencesViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var commands: [CommandModel] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // TEST
        let command = CommandModel()
        command.name = "test"
        command.script = "script"
        command.key = "k"
        self.commands = [command]
    }
    
    @IBAction func onAddCommandButtonClicked(_ sender: NSButton) {
        // TODO: add command
    }
    
    @IBAction func onRemoveButtonClicked(_ sender: NSButton) {
        if (tableView.numberOfSelectedRows < 1) {
            log.warning("no row selected")
            return
        }
        // TODO: remove command
    }
    
    // MARK: NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.commands.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let identifier = tableColumn?.identifier
        let command = self.commands[row]
        return identifier == "name" ? command.name : command.key
    }

    // MARK: MASPreferencesViewController
    override var identifier: String? {
        get { return "KeyBindingsPreferences" }
        set { super.identifier = newValue }
    }
    
    var toolbarItemImage: NSImage! = NSImage(named: NSImageNamePreferencesGeneral)
    
    var toolbarItemLabel: String! = "Key Bindings"
}
