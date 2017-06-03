//
//  Devices.swift
//  TySimulator
//
//  Created by yinhun on 16/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class Device: NSObject {
    private var deviceObservingContext = 0
    
    public static let DevicesChangedNotification = "DevicesChangedNotification"
    
    private static let sharedInstance = Device()
    var devices: [DeviceModel] = []
    
    override init() {
        super.init()
        self.updateDeivces()
        Preference.shared.addObserver(self, forKeyPath: "onlyAvailableDevices", options: [.new], context: &deviceObservingContext)
        Preference.shared.addObserver(self, forKeyPath: "onlyHasContentDevices", options: [.new], context: &deviceObservingContext)
    }
    
    deinit {
        Preference.shared.removeObserver(self, forKeyPath: "onlyAvailableDevices", context: &deviceObservingContext)
        Preference.shared.removeObserver(self, forKeyPath: "onlyHasContentDevices", context: &deviceObservingContext)
    }
    
    static func shared() -> Device {
        return sharedInstance
    }
    
    func device(udid: String) -> DeviceModel? {
        for device in devices {
            if device.udid == udid {
                return device
            }
        }
        return nil
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
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Device.DevicesChangedNotification), object: nil)
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
    
    // MARK: Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &deviceObservingContext {
            if (change?[NSKeyValueChangeKey.newKey]) != nil {
                self.updateDeivces()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

}
