//
//  Process.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation

extension Process {
    class func output(launchPath: String, arguments: [String], directoryPath: URL? = nil) -> String {
        let output = Pipe()
        
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        task.standardOutput = output
        
        if let path = directoryPath?.removeTrailingSlash.path {
            task.currentDirectoryPath = path
        }
        
        task.launch()
        
        // For some reason [task waitUntilExit]; does not return sometimes. Therefore this rather hackish solution:
        var count = 0
        while task.isRunning && count < 10 {
            Thread.sleep(forTimeInterval: 0.1)
            count += 1
        }
        
        let data = output.fileHandleForReading.readDataToEndOfFile()
        guard let result = String(data: data, encoding: .utf8) else {
            return ""
        }
        
        return result
    }
    
    @discardableResult
    class func execute(_ script: String) -> String {
        let scriptCLI = Script.transformedScript(script)
        log.info("run script: \(scriptCLI)")
        return output(launchPath: "/bin/sh", arguments: ["-c", scriptCLI])
    }
    
}
