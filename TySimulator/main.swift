//
//  main.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import SwiftyBeaver

let log = SwiftyBeaver.self
let console = ConsoleDestination()
log.addDestination(console)

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
