//
//  Devices.swift
//  TySimulator
//
//  Created by luckytianyiyan on 16/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import SwiftyJSON

class Device: NSObject {
    private var deviceObservingContext = 0
    
    public static let DevicesChangedNotification: NSNotification.Name = NSNotification.Name(rawValue: "DevicesChangedNotification")
    
    static let shared = Device()
    var devices: [DeviceModel] = []
    
    override init() {
        super.init()
        updateDeivces()
        Preference.shared.addObserver(self, forKeyPath: "onlyAvailableDevices", options: [.new], context: &deviceObservingContext)
        Preference.shared.addObserver(self, forKeyPath: "onlyHasContentDevices", options: [.new], context: &deviceObservingContext)
    }
    
    deinit {
        Preference.shared.removeObserver(self, forKeyPath: "onlyAvailableDevices", context: &deviceObservingContext)
        Preference.shared.removeObserver(self, forKeyPath: "onlyHasContentDevices", context: &deviceObservingContext)
    }
    
    func device(udid: String) -> DeviceModel? {
        return devices.first(where: { $0.udid == udid })
    }
    
    func updateDeivces() {
        let output = Process.output(launchPath: "/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"],
                                    directoryPath: Device.devicesDirectory)
        
        let json = JSON(parseJSON: output)
        
        var devices: [DeviceModel] = []
        
        for (key, value) in json["devices"].dictionaryValue {
            for simulatorJSON in value.arrayValue {
                let osInfo = key.replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
                let device = DeviceModel(osInfo: osInfo, json: simulatorJSON.dictionaryObject!)
                devices.append(device)
            }
        }
        
        self.devices = devices.filter {
            var result = $0.os != .unknown
            let preference = Preference.shared
            if preference.onlyAvailableDevices {
                result = result && $0.isAvailable
            }
            if preference.onlyHasContentDevices {
                result = result && $0.hasContent
            }
            return result
            }.sorted {
                return $0.osInfo.compare($1.osInfo) == .orderedAscending
        }
        
        NotificationCenter.default.post(name: Device.DevicesChangedNotification, object: nil)
    }
    
    static func bootedDevices() -> [DeviceModel] {
        let output = Process.output(launchPath: "/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"],
                                    directoryPath: devicesDirectory)
        
        let json = JSON(parseJSON: output)
        
        var devices: [DeviceModel] = []
        
        for (key, value) in json["devices"].dictionaryValue {
            for simulatorJSON in value.arrayValue {
                let osInfo = key.replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
                let booted = simulatorJSON["state"].stringValue.contains("Booted")
                if booted {
                    devices.append(DeviceModel(osInfo: osInfo, json: simulatorJSON.dictionaryObject!))
                }
            }
        }
        
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
    
    // MARK: Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &deviceObservingContext, (change?[NSKeyValueChangeKey.newKey]) != nil {
            updateDeivces()
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

}
