//
//  KeyBindingsPreferencesViewController.swift
//  TySimulator
//
//  Created by yinhun on 16/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import MASPreferences
import MASShortcut

class KeyBindingsPreferencesViewController: NSViewController, MASPreferencesViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var commands: [CommandModel]?
    
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
        return self.commands?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let command = self.commands?[row] else {
            log.warning("no command found at row: \(row)")
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            if let cell = tableView.make(withIdentifier: "NameTableCellViewIdentifier", owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = command.name
                cell.textField?.isEditable = true
                return cell
            }
        } else if tableColumn == tableView.tableColumns[1] {
            if let cell = tableView.make(withIdentifier: "ShortcutTableCellViewIdentifier", owner: nil) as? ShortcutTableCellView {
                cell.shortcutView?.shortcutValueChange = {(sender: MASShortcutView?) in
                    log.info("shortcut changed: \(sender?.shortcutValue)")
                }
                return cell
            }
        }
        
        return nil
    }

    // MARK: MASPreferencesViewController
    override var identifier: String? {
        get { return "KeyBindingsPreferences" }
        set { super.identifier = newValue }
    }
    
    var toolbarItemImage: NSImage! = NSImage(named: NSImageNamePreferencesGeneral)
    
    var toolbarItemLabel: String! = "Key Bindings"
}
