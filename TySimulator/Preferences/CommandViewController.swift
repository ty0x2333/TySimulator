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
    var command: CommandModel!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var shortcutView: MASShortcutView!
    @IBOutlet var scriptTextView: NSTextView!
    var save: ((CommandModel) -> ())?
    
    init(_ command: CommandModel) {
        super.init(nibName: nil, bundle: nil)!
        self.command = command
    }
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.command = CommandModel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Command Editor"
        self.nameTextField.bind("value", to: self.command, withKeyPath: #keyPath(CommandModel.name), options: [NSContinuouslyUpdatesValueBindingOption: true])
        self.shortcutView.bind("shortcutValue", to: self.command, withKeyPath: #keyPath(CommandModel.key), options: [NSContinuouslyUpdatesValueBindingOption: true])
        self.scriptTextView.bind("value", to: self.command, withKeyPath: #keyPath(CommandModel.script), options: [NSContinuouslyUpdatesValueBindingOption: true])
        
        let (deviceIdentifier, applicationIdentifier) = self.placeholderDevice()
        
        self.scriptTextView.placeHolderString = "open ${\"device\": \"\(deviceIdentifier)\", \"application\": \"\(applicationIdentifier)\"}"
    }
    
    func placeholderDevice() -> (String, String) {
        var deviceIdentifier = "booted"
        
        // try booted device
        if let device = Device.bootedDevices().first {
            if device.applications.count > 0 {
                return (deviceIdentifier, (device.applications.first?.bundleIdentifier)!)
            }
        }
        
        // try other device
        for it in Device.shared().devices {
            deviceIdentifier = it.udid
            if it.applications.count > 0 {
                return (deviceIdentifier, (it.applications.first?.bundleIdentifier)!)
            }
        }
        return (deviceIdentifier, "your_app_bundle_identifier")
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
