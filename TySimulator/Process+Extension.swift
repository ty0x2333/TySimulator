//
//  Process+Extension.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation

extension Process {
    static func output(launchPath: String, arguments: [String], directoryPath: URL? = nil) -> String {
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
        var count = 0;
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
    
    static func execute(_ script: String) -> String {
        var scriptCLI = script
        if let device = Device.bootedDevices().first {
            scriptCLI = script.replacingOccurrences(of: "$(BOOTED_DEVICE_LOCATION)", with:device.location.absoluteString)
        }
        log.info("run script: \(scriptCLI)")
        return self.output(launchPath: "/bin/sh", arguments: ["-c", scriptCLI])
    }
    
    class func environmentKeyDescriptions() -> Dictionary<String, String> {
        return ["BOOTED_DEVICE_LOCATION": "Booted Device Folder"]
    }
}
