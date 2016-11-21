//
//  CommandViewController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/21.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import MASShortcut

class CommandViewController: NSViewController {
    @IBOutlet var command: CommandModel!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var shortcutView: MASShortcutView!
    @IBOutlet var scriptTextView: NSTextView!
    var save: ((CommandModel) -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Command Editor"
        self.nameTextField.bind("value", to: self.command, withKeyPath: "name", options: [NSContinuouslyUpdatesValueBindingOption: true])
        self.shortcutView.bind("shortcutValue", to: self.command, withKeyPath: "key", options: [NSContinuouslyUpdatesValueBindingOption: true])
        self.scriptTextView.bind("value", to: self.command, withKeyPath: "script", options: [NSContinuouslyUpdatesValueBindingOption: true])
    }
    
    @IBAction func onSaveButtonClicked(_ sender: NSButton) {
        // TODO: log
        self.save?(self.command)
        self.dismiss(self)
    }
    
    @IBAction func onCancelButtonClicked(_ sender: NSButton) {
        // TODO: log
        self.dismiss(self)
    }
}
