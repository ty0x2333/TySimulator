//
//  main.swift
//  TySimulator
//
//  Created by ty0x2333 on 2016/11/13.
//  Copyright © 2016年 ty0x2333. All rights reserved.
//

import Cocoa
import SwiftyBeaver

let log = SwiftyBeaver.self
let console = ConsoleDestination()
log.addDestination(console)

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
