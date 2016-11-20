//
//  CommandViewController.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/21.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class CommandViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Command Editor"
    }
    @IBAction func onSaveButtonClicked(_ sender: NSButton) {
        // TODO: save, log
        self.dismiss(self)
    }
    
    @IBAction func onCancelButtonClicked(_ sender: NSButton) {
        // TODO: log
        self.dismiss(self)
    }
}
