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
        
        self.devices = Device.listDevices().filter {
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
    
    class func listDevices() -> [DeviceModel] {
        let output = Process.output(launchPath: "/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"])
        
        let json = JSON(parseJSON: output)
        
        var devices: [DeviceModel] = []
        
        for (key, value) in json["devices"].dictionaryValue {
            let osInfo = key.replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
            devices.append(contentsOf: value.arrayValue.map { DeviceModel(osInfo: osInfo, json: $0.dictionaryObject!) })
        }
        return devices
    }
    
    class func bootedDevices() -> [DeviceModel] {
        let devices: [DeviceModel] = listDevices().filter { return $0.hasContent && $0.isAvailable && $0.os != .unknown && $0.isOpen }
        
        return devices.sorted { return $0.osInfo.compare($1.osInfo) == .orderedAscending }
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
