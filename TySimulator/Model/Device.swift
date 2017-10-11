//
//  Devices.swift
//  TySimulator
//
//  Created by luckytianyiyan on 16/11/17.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import SwiftyJSON

extension Notification.Name {
    public struct Device {
        public static let DidChange = Notification.Name(rawValue: "com.tianyiyan.notification.device.didChange")
        public struct Booted {
            public static let DidChange = Notification.Name(rawValue: "com.tianyiyan.notification.device.booted.didChange")
        }
    }
}

class Device: NSObject {
    static let shared = Device()
    private(set) var devices: [DeviceModel] = []
    private(set) var bootedDevices: [DeviceModel] = []
    var deviceContentToken: NSKeyValueObservation?
    var deviceAvailableToken: NSKeyValueObservation?
    
    override init() {
        super.init()
        updateDeivces()
        deviceContentToken = Preference.shared.observe(\.onlyHasContentDevices, options: [.new]) { [weak self] _, _ in
            self?.updateDeivces()
        }
        deviceAvailableToken = Preference.shared.observe(\.onlyAvailableDevices, options: [.new]) { [weak self] _, _ in
            self?.updateDeivces()
        }
    }
    
    deinit {
        deviceContentToken?.invalidate()
        deviceAvailableToken?.invalidate()
    }
    
    func device(udid: String) -> DeviceModel? {
        return devices.first(where: { $0.udid == udid })
    }
    
    func updateDeivces() {
        
        let allDevices = Device.listDevices()
        devices = allDevices.filter {
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
                $0.osInfo.compare($1.osInfo) == .orderedAscending
        }
        
        let bootedDevices = allDevices.filter {
                $0.hasContent && $0.isAvailable && $0.os != .unknown && $0.isOpen
            }.sorted {
                $0.osInfo.compare($1.osInfo) == .orderedAscending
        }
        
        NotificationCenter.default.post(name: Notification.Name.Device.DidChange, object: nil)
        
        let areInIncreasingOrder: ((DeviceModel, DeviceModel) -> Bool) = { (lhs, rhs) -> Bool in
            return lhs.udid > rhs.udid
        }
        
        let hasChanged = bootedDevices.sorted(by: areInIncreasingOrder) != self.bootedDevices.sorted(by: areInIncreasingOrder)
        self.bootedDevices = bootedDevices
        if hasChanged {
            NotificationCenter.default.post(name: Notification.Name.Device.Booted.DidChange, object: nil)
        }
    }
    
    static var devicesDirectory: URL {
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
        return URL(fileURLWithPath: path).appendingPathComponent("Developer/CoreSimulator/Devices")
    }

}

extension Device {
    fileprivate class func listDevices() -> [DeviceModel] {
        let output = Process.output(launchPath: "/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"])
        
        let json = JSON(parseJSON: output)
        
        var devices: [DeviceModel] = []
        
        for (key, value) in json["devices"].dictionaryValue {
            let osInfo = key.replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
            devices.append(contentsOf: value.arrayValue.map { DeviceModel(osInfo: osInfo, json: $0.dictionaryObject!) })
        }
        return devices
    }
}
