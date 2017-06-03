//
//  ShortcutMonitor.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/24.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import MASShortcut

extension MASShortcutMonitor {
    func register(command: CommandModel) {
        guard command.key != nil else {
            log.warning("register faild, command shortcut is nil")
            return
        }
        self.register(command.key, withAction: {
            NSSound(named: "Ping")?.play()
            log.debug("script: \(command.script)")
            Process.execute(command.script)
        })
    }
    
    func unregister(command: CommandModel) {
        guard command.key != nil else {
            log.warning("unregister faild, command shortcut is nil")
            return
        }
        self.unregisterShortcut(command.key)
    }
}
