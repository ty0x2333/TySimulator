//
//  KeyBindingsPreferencesViewController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 16/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import MASPreferences
import MASShortcut

class KeyBindingsPreferencesViewController: NSViewController, MASPreferencesViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var commandController: NSArrayController = NSArrayController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.doubleAction = #selector(onTableViewDoubleClicked(_:))
    }
    
    // MARK: Actions
    func onTableViewDoubleClicked(_ sender: NSTableView) {
        log.verbose("click row: \(sender.clickedRow)")
        let command = Preference.shared.commands[sender.clickedRow]
        let commandViewController = CommandViewController(command)
        let oldKey = command.key
        commandViewController.save = { [weak self] (command) in
            log.verbose("save command: \(command)")
            MASShortcutMonitor.shared().unregisterShortcut(oldKey)
            Preference.shared.setCommand(id: command.id, command: command)
            MASShortcutMonitor.shared().register(command: command)
            self?.tableView.reloadData()
        }
        presentViewControllerAsSheet(commandViewController)
    }
    
    @IBAction func onAddCommandButtonClicked(_ sender: NSButton) {
        let commandViewController = CommandViewController()
        commandViewController.save = { [weak self] (command) in
            log.verbose("save command: \(command)")
            MASShortcutMonitor.shared().register(command: command)
            Preference.shared.append(command)
            self?.tableView.reloadData()
        }
        presentViewControllerAsSheet(commandViewController)
    }
    
    @IBAction func onRemoveButtonClicked(_ sender: NSButton) {
        if tableView.numberOfSelectedRows < 1 {
            log.warning("no row selected")
            return
        }
        let preference = Preference.shared
        let command = preference.commands[tableView.selectedRow]
        MASShortcutMonitor.shared().unregister(command: command)
        Preference.shared.remove(commandAt: tableView.selectedRow)
        tableView.reloadData()
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Preference.shared.commands.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let command = Preference.shared.commands[row]
        
        if tableColumn == tableView.tableColumns[0] {
            if let cell = tableView.make(withIdentifier: "NameTableCellViewIdentifier", owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = command.name
                return cell
            }
        } else if tableColumn == tableView.tableColumns[1] {
            if let cell = tableView.make(withIdentifier: "ShortcutTableCellViewIdentifier", owner: nil) as? ShortcutTableCellView {
                cell.shortcutView?.shortcutValue = command.key
                cell.shortcutView?.shortcutValueChange = {(sender: MASShortcutView?) in
                    MASShortcutMonitor.shared().unregister(command: command)
                    command.key = sender?.shortcutValue
                    Preference.shared.setCommand(id: command.id, command: command)
                    MASShortcutMonitor.shared().register(command: command)
                    log.info("row: \(row), shortcut changed: \(String(describing: sender?.shortcutValue))")
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
    
    var toolbarItemImage: NSImage! = NSImage(named: NSImageNameAdvanced)
    
    var toolbarItemLabel: String! = "Key Bindings"
}
