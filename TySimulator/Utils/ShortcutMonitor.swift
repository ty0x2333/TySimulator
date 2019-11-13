//
//  ShortcutMonitor.swift
//  TySimulator
//
//  Created by ty0x2333 on 2016/11/24.
//  Copyright © 2016年 ty0x2333. All rights reserved.
//

import MASShortcut

extension MASShortcutMonitor {
    func register(command: CommandModel) {
        guard command.key != nil else {
            log.warning("register faild, command shortcut is nil")
            return
        }
        register(command.key, withAction: {
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
        unregisterShortcut(command.key)
    }
}
