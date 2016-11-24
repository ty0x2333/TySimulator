//
//  MASShortcutMonitor+Command.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/24.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import MASShortcut

extension MASShortcutMonitor {
    func register(command: CommandModel) {
        self.register(command.key, withAction: {
            NSSound(named: "Ping")?.play()
            log.debug("script: \(command.script)")
            Process.execute(command.script)
        })
    }
    
    func unregister(command: CommandModel) {
        self.unregisterShortcut(command.key)
    }
}
