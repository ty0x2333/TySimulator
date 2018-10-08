//
//  Simulator.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2018/10/8.
//  Copyright © 2018 luckytianyiyan. All rights reserved.
//

import Foundation

extension Notification.Name {
    public struct Device {
        public static let DidChange = Notification.Name(rawValue: "com.tianyiyan.notification.device.didChange")
        public static let BootedDidChange = Notification.Name(rawValue: "com.tianyiyan.notification.device.booted.didChange")
    }
}

class Simulator {
    static let shared = Simulator()
    private(set) var devices: [DeviceModel] = []
    private(set) var bootedDevices: [DeviceModel] = []
    var deviceContentToken: NSKeyValueObservation?
    var deviceAvailableToken: NSKeyValueObservation?
    
    init() {
        let changeHandler: (Preference, NSKeyValueObservedChange<Bool>) -> Void = { [weak self] _, _ in
            DispatchQueue.global().async {
                self?.updateDeivces()
            }
        }
        deviceContentToken = Preference.shared.observe(\.onlyHasContentDevices, options: [.new], changeHandler: changeHandler)
        deviceAvailableToken = Preference.shared.observe(\.onlyAvailableDevices, options: [.new], changeHandler: changeHandler)
    }
    
    deinit {
        deviceContentToken?.invalidate()
        deviceAvailableToken?.invalidate()
    }
    
    func updateDeivces() {
        
        let allDevices = Simulator.listDevices()
        let preference = Preference.shared
        var filter: [DeviceFilter] = []
        if preference.onlyAvailableDevices {
            filter.append(.onlyAvailableDevices)
        }
        if preference.onlyHasContentDevices {
            filter.append(.onlyHasContentDevices)
        }
        devices = Simulator.listSortedDevices(filter: filter, descending: false)
        
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
            NotificationCenter.default.post(name: Notification.Name.Device.BootedDidChange, object: nil)
        }
    }
    
    static var devicesDirectory: URL {
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
        return URL(fileURLWithPath: path).appendingPathComponent("Developer/CoreSimulator/Devices")
    }
    
    func device(udid: String) -> DeviceModel? {
        return devices.first(where: { $0.udid == udid })
    }
}

extension Simulator {
    struct DeviceFilter: OptionSet {
        let rawValue: Int
        
        static let onlyAvailableDevices = DeviceFilter(rawValue: 1 << 1)
        static let onlyHasContentDevices = DeviceFilter(rawValue: 1 << 2)
    }

    class func listDevices(filter: [DeviceFilter] = []) -> [DeviceModel] {
        let data = Process.outputData(launchPath: "/usr/bin/xcrun", arguments: ["simctl", "list", "-j", "devices"])
        
        let deviceObjs = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        
        var devices: [DeviceModel] = []
        
        guard let dic = deviceObjs as? [String: [String: Any]], let deviceDic = dic["devices"] else {
            return []
        }
        deviceDic.forEach { (key, value) in
            let osInfo = key.replacingOccurrences(of: "com.apple.CoreSimulator.SimRuntime.", with: "")
            if let arrayValue = value as? [[String: Any]] {
                let models = arrayValue.map { DeviceModel(osInfo: osInfo, json: $0) }
                devices.append(contentsOf: models)
            }
        }
        
        devices = devices.filter {
            var result = $0.os != .unknown
            if filter.contains(.onlyAvailableDevices) {
                result = result && $0.isAvailable
            }
            if filter.contains(.onlyHasContentDevices) {
                result = result && $0.hasContent
            }
            return result
        }
        
        return devices
    }
    
    class func listSortedDevices(filter: [DeviceFilter] = [], descending: Bool) -> [DeviceModel] {
        return listDevices(filter: filter).sorted {
            $0.osInfo.compare($1.osInfo) == (descending ? .orderedDescending : .orderedAscending)
        }
    }
}
