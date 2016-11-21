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

class KeyBindingsPreferencesViewController: NSViewController, MASPreferencesViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var commands: [CommandModel]?
    var commandController: NSArrayController = NSArrayController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commands = Preference.commands
        self.tableView.doubleAction = #selector(onTableViewDoubleClicked(_:))
    }
    
    // MARK: Actions
    func onTableViewDoubleClicked(_ sender: NSTableView) {
        log.verbose("click row: \(sender.clickedRow)")
    }
    
    @IBAction func onAddCommandButtonClicked(_ sender: NSButton) {
        let commandViewController = CommandViewController()
        commandViewController.save = { (command) in
            log.verbose("save command: \(command)")
            MASShortcutMonitor.shared().register(command.key, withAction: { 
                NSSound(named: "Ping")?.play()
                log.debug("script: \(command.script)")
                Process.execute(command.script)
            })
            self.commands?.append(command)
            Preference.commands = self.commands!
            self.tableView.reloadData()
        }
        self.presentViewControllerAsModalWindow(commandViewController)
    }
    
    @IBAction func onRemoveButtonClicked(_ sender: NSButton) {
        if (tableView.numberOfSelectedRows < 1) {
            log.warning("no row selected")
            return
        }
        // TODO: remove command
        let command = self.commands?[self.tableView.selectedRow]
        if let shortcut = command?.key {
            MASShortcutMonitor.shared().unregisterShortcut(shortcut)
        }
        self.commands?.remove(at: self.tableView.selectedRow)
        Preference.commands = self.commands!
        self.tableView.reloadData()
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
                return cell
            }
        } else if tableColumn == tableView.tableColumns[1] {
            if let cell = tableView.make(withIdentifier: "ShortcutTableCellViewIdentifier", owner: nil) as? ShortcutTableCellView {
                cell.shortcutView?.shortcutValue = command.key
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
