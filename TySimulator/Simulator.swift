//
//  Simulator.swift
//  TySimulator
//
//  Created by ty0x2333 on 2018/10/8.
//  Copyright © 2018 ty0x2333. All rights reserved.
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
            $0.displayName.compare($1.displayName) == .orderedAscending
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name.Device.DidChange, object: nil)
        }
        
        let areInIncreasingOrder: ((DeviceModel, DeviceModel) -> Bool) = { (lhs, rhs) -> Bool in
            return lhs.udid > rhs.udid
        }
        
        let hasChanged = bootedDevices.sorted(by: areInIncreasingOrder) != self.bootedDevices.sorted(by: areInIncreasingOrder)
        self.bootedDevices = bootedDevices
        if hasChanged {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.Device.BootedDidChange, object: nil)
            }
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
    
    // MARK: Device

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
    
    class func devicePath(udid: String) -> URL {
        return Simulator.devicesDirectory.appendingPathComponent("\(udid)")
    }
    
    // MARK: Media
    
    class func medias(path: URL) -> [MediaModel] {
        let directory = path.appendingPathComponent("/data/Media/DCIM")
        
        return FileManager.directories(directory).map {
            let media = MediaModel(name: $0, location: directory.appendingPathComponent($0))
            return media
        }
    }
    
    // MARK: Application
    
    class func applicationsDataPath(deviceUDID: String) -> URL {
        let devicePath = Simulator.devicePath(udid: deviceUDID)
        return devicePath.appendingPathComponent("data/Containers/Data/Application")
    }
    
    class func applicationsBundlePath(deviceUDID: String) -> URL {
        let devicePath = Simulator.devicesDirectory.appendingPathComponent("\(deviceUDID)")
        return devicePath.appendingPathComponent("data/Containers/Bundle/Application")
    }
    
    class func applications(deviceUDID: String) -> [ApplicationModel] {
        let bundlesDirectory = Simulator.applicationsBundlePath(deviceUDID: deviceUDID)
        let applicationDirectories = FileManager.directories(bundlesDirectory)
        var result: [ApplicationModel] = []
        for uuid in applicationDirectories {
            if let bundle = applicationBundle(deviceUDID: deviceUDID, applicationUUID: uuid),
                let dataPath = findApplicationDataPath(deviceUDID: deviceUDID, bundleID: bundle.bundleID),
                let application = ApplicationModel(deviceUDID: deviceUDID, uuid: uuid, bundle: bundle, dataPath: dataPath) {
                result.append(application)
            }
        }
        return result
    }
    
    class func applicationBundle(deviceUDID: String, applicationUUID: String) -> ApplicationBundle? {
        let bundlesDirectory = Simulator.applicationsBundlePath(deviceUDID: deviceUDID)
        let bundlePath = bundlesDirectory.appendingPathComponent(applicationUUID)
        
        guard let appIAPDirectory = FileManager.directories(bundlePath).first,
            let json = NSDictionary(contentsOf: bundlePath.appendingPathComponent("\(appIAPDirectory)/Info.plist")),
            let bundleID = json["CFBundleIdentifier"] as? String else {
                return nil
        }
        
        let name = (json["CFBundleName"] as? String) ?? "Unknow"
        let icon: NSImage?
        if let bundleIcons = json["CFBundleIcons"] as? [String: Any],
            let primaryIcon = bundleIcons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let iconFile = iconFiles.last {
            icon = NSImage(contentsOf: bundlePath.appendingPathComponent("\(appIAPDirectory)/\(iconFile)@3x.png"))
        } else {
            icon = nil
        }
        
        return ApplicationBundle(bundleID: bundleID, appName: name, appIcon: icon)
    }
    
    class func findApplicationDataPath(deviceUDID: String, bundleID: String) -> URL? {
        let directory = Simulator.applicationsDataPath(deviceUDID: deviceUDID)
        
        let plist = ".com.apple.mobile_container_manager.metadata.plist"
        for udid in FileManager.directories(directory) {
            let dataPath = directory.appendingPathComponent(udid)
            let plistPath = dataPath.appendingPathComponent(plist)
            guard let json = NSDictionary(contentsOf: plistPath),
                let metaDataIdentifier = json["MCMMetadataIdentifier"] as? String,
                metaDataIdentifier == bundleID else {
                continue
            }
            
            return dataPath
        }
        return nil
    }
    
    // MARK: AppGroup
    
    class func appGroups(deviceUDID: String) -> [AppGroupModel] {
        let devicePath = Simulator.devicesDirectory.appendingPathComponent("\(deviceUDID)")
        let directory = devicePath.appendingPathComponent("/data/Containers/Shared/AppGroup")
        return FileManager.directories(directory).map {
            let appGroup = AppGroupModel()
            appGroup.location = directory.appendingPathComponent($0)
            
            let plistPath = appGroup.location!.appendingPathComponent("/.com.apple.mobile_container_manager.metadata.plist")
            let json = NSDictionary(contentsOf: plistPath)
            
            appGroup.bundleIdentifier = json?["MCMMetadataIdentifier"] as? String ?? ""
            
            return appGroup
        }.filter {
            return !$0.bundleIdentifier.contains("com.apple")
        }
    }
}
