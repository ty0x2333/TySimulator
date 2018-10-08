//
//  Script.swift
//  TySimulator
//
//  Created by luckytianyiyan on 16/12/29.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Script {
    public class func transformedScript(_ script: String) -> String {
        var result = script
        var res: [NSTextCheckingResult] = []
        do {
            let regex = try NSRegularExpression(pattern: "\\$\\{\\{[\\s\\S]*?\\}\\}", options: NSRegularExpression.Options.caseInsensitive)
            res = regex.matches(in: script, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: script.count))
        } catch {
            log.error(error)
        }
        guard res.count > 0 else {
            return script
        }
        for checkingRes in res {
            var commandValue = (script as NSString).substring(with: checkingRes.range)
            commandValue = (commandValue as NSString).substring(with: NSRange(location: 2, length: commandValue.count - 3)
)
            let command = JSON(parseJSON: commandValue)
            let deviceId = command["device"].stringValue
            
            guard !deviceId.isEmpty else {
                log.warning("device id is empty")
                continue
            }
            
            guard let device = (deviceId != "booted") ? Device.shared.device(udid: deviceId) : Device.shared.bootedDevices.first else {
                log.warning("no device: \(deviceId)")
                continue
            }
            
            if let bundleIdentifier = command["application"].string,
                let application = device.application(bundleIdentifier: bundleIdentifier),
                let location = application.loadDataLocation()?.removeTrailingSlash?.absoluteString {
                
                result = (result as NSString).replacingCharacters(in: checkingRes.range, with: location)
            }
        }
        return result
    }
    
    public class func transformedValue(deviceIdentifier: String, applicationIdentifier: String) -> String {
        return "${{\"device\": \"\(deviceIdentifier)\", \"application\": \"\(applicationIdentifier)\"}}"
    }
}
