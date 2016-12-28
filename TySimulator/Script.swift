//
//  Script.swift
//  TySimulator
//
//  Created by luckytianyiyan on 16/12/29.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation

public class Script {
    public class func transformedScript(_ script: String) throws -> String {
        var result = script
        var res: [NSTextCheckingResult] = []
        do {
            let regex = try NSRegularExpression(pattern:"\\$\\{\\{.*\\}\\}", options:NSRegularExpression.Options.caseInsensitive)
            res = regex.matches(in:script, options:NSRegularExpression.MatchingOptions(rawValue: 0), range:NSMakeRange(0, script.characters.count))
        } catch {
            log.error(error)
        }
        guard res.count > 0 else {
            return script
        }
        for checkingRes in res {
            var commandValue = (script as NSString).substring(with:checkingRes.range)
            commandValue = (commandValue as NSString).substring(with: NSMakeRange(2, commandValue.characters.count - 3))
            if let command = try JSONSerialization.jsonObject(with: commandValue.data(using: .utf8)!, options: []) as? Dictionary<String, String> {
                if let deviceId = command["device"] {
                    var device: DeviceModel?
                    if deviceId != "booted" {
                        device = Device.shared().device(udid: deviceId)
                    } else {
                        device = Device.bootedDevices().first
                    }
                    guard device != nil else {
                        log.warning("no device: \(deviceId)")
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
        }
        return result
    }
    
    public class func transformedValue(deviceIdentifier: String, applicationIdentifier: String) -> String {
        return "${{\"device\": \"\(deviceIdentifier)\", \"application\": \"\(applicationIdentifier)\"}}"
    }
}
