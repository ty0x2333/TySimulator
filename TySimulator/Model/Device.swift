//
//  Devices.swift
//  TySimulator
//
//  Created by yinhun on 16/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class Device {
    private static let sharedInstance = Device()
    var devices: [DeviceModel] = []
    
    init() {
        self.updateDeivces()
    }
    
    static func shared() -> Device {
        return sharedInstance
    }
    
    func updateDeivces() {
        let string = Process.output(launchPath: "/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"],
                                    directoryPath: Device.devicesDirectory)
        
        guard let data = string.data(using: String.Encoding.utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
            let json = jsonObject
            else {
                self.devices = []
                return
        }
        
        var devices: [DeviceModel] = []
        
        let deviceObjects = json["devices"] as? NSDictionary
        
        deviceObjects?.forEach({ (key, value) in
            let simulators = value as? NSArray
            simulators?.forEach({ (simulatorJSON) in
                let osInfo = (key as! String).replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
                let device = DeviceModel(osInfo: osInfo, json: simulatorJSON as! NSDictionary)
                devices.append(device)
            })
        })
        
        self.devices = devices.filter {
            var result = $0.os != .unknown
            if Preferences.onlyAvailableDevices {
                result = result && $0.isAvailable
            }
            if Preferences.onlyHasContentDevices {
                result = result && $0.hasContent
            }
            return result
            }.sorted {
                return $0.osInfo.compare($1.osInfo) == .orderedAscending
        }
    }
    
    static func bootedDevices() -> [DeviceModel] {
        let string = Process.output(launchPath: "/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"],
                                    directoryPath: self.devicesDirectory)
        
        guard let data = string.data(using: String.Encoding.utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
            let json = jsonObject
            else { return [] }
        
        var devices: [DeviceModel] = []
        
        let deviceObjects = json["devices"] as? NSDictionary
        
        deviceObjects?.forEach({ (key, value) in
            let simulators = value as? NSArray
            simulators?.forEach({ (simulatorJSON) in
                let osInfo = (key as! String).replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
                let json = simulatorJSON as! NSDictionary
                let booted = (json["state"] as! String).contains("Booted")
                if booted {
                    devices.append(DeviceModel(osInfo: osInfo, json: json))
                }
            })
        })
        
        return devices.filter {
            return $0.hasContent && $0.isAvailable && $0.os != .unknown
            }.sorted {
                return $0.osInfo.compare($1.osInfo) == .orderedAscending
        }
    }
    
    static var devicesDirectory: URL {
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
        return URL(fileURLWithPath: path).appendingPathComponent("Developer/CoreSimulator/Devices")
    }

}
