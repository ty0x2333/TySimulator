//
//  DeviceModel.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation

enum OS: String {
    case tvOS = "tvOS"
    case iOS = "iOS"
    case watchOS = "watchOS"
    case unknown = "unknown"
    
    var order: Int {
        switch self {
        case .iOS:
            return 0
        case .tvOS:
            return 1
        case .watchOS:
            return 2
        default:
            return 3
        }
    }
}

class DeviceModel {
    
    let name: String
    let udid: String
    let osInfo: String
    let isOpen: Bool
    let isAvailable: Bool
    
    var applications: [ApplicationModel] = []
    var medias: [MediaModel] = []
    var appGroups: [AppGroupModel] = []
    
    init(osInfo: String, json: NSDictionary) {
        self.name = json["name"] as! String
        self.udid = json["udid"] as! String
        self.isAvailable = (json["availability"] as! String).contains("(available)")
        self.isOpen = (json["state"] as! String).contains("Booted")
        self.osInfo = osInfo
        
        self.applications = ApplicationModel.applications(path: location)
        self.appGroups = AppGroupModel.groups(location)
        self.medias = MediaModel.medias(location)
    }
    
    var hasContent: Bool {
        return !applications.isEmpty
    }
    
    var os: OS {
        return OS(rawValue: osInfo.components(separatedBy: " ").first ?? "") ?? .unknown
    }
    
    var location: URL {
        return DeviceModel.devicesDirectory.appendingPathComponent("\(self.udid)")
    }
    
    var version: String {
        return osInfo.components(separatedBy: " ").last ?? ""
    }

    static func devices() -> [DeviceModel] {
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
                let device = DeviceModel(osInfo: osInfo, json: simulatorJSON as! NSDictionary)
                devices.append(device)
            })
        })
        
        return devices.filter {
            return $0.hasContent && $0.isAvailable && $0.os != .unknown
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
