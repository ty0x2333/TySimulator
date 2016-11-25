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
    
    public class func transformedScript(_ script: String) -> String {
        var result = script
        var res: [NSTextCheckingResult] = []
        do {
            let regex = try NSRegularExpression(pattern:"\\$\\{.*\\}", options:NSRegularExpression.Options.caseInsensitive)
            res = regex.matches(in:script, options:NSRegularExpression.MatchingOptions(rawValue: 0), range:NSMakeRange(0, script.characters.count))
        } catch {
            log.error(error)
        }
        guard res.count > 0 else {
            return script
        }
        for checkingRes in res {
            var commandValue = (script as NSString).substring(with:checkingRes.range)
            commandValue = (commandValue as NSString).substring(from: 1)
            do {
                if let command = try JSONSerialization.jsonObject(with: commandValue.data(using: .utf8)!, options: []) as? Dictionary<String, String> {
                    if let deviceId = command["device"] {
                        var device: DeviceModel?
                        if deviceId != "booted" {
                            device = Device.shared().device(udid: deviceId)
                        } else {
                            device = Device.bootedDevices().first
                        }
                        guard device != nil else {
                            continue
                        }
                        if let bundleIdentifier = command["application"] {
                            if let application = device?.application(bundleIdentifier: bundleIdentifier) {
                                if let location = application.loadDataLocation()?.removeTrailingSlash.absoluteString {
                                    result = (result as NSString).replacingCharacters(in: checkingRes.range, with: location)
                                }
                            }
                        }
                    }
                }
            } catch {
                log.error(error)
            }
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
    
}
