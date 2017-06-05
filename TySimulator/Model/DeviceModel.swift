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
    
    init(osInfo: String, json: [String: Any]) {
        name = json["name"] as! String
        udid = json["udid"] as! String
        isAvailable = (json["availability"] as! String).contains("(available)")
        isOpen = (json["state"] as! String).contains("Booted")
        self.osInfo = osInfo
        
        applications = ApplicationModel.applications(path: location)
        appGroups = AppGroupModel.groups(location)
        medias = MediaModel.medias(location)
    }
    
    var hasContent: Bool {
        return !applications.isEmpty
    }
    
    var os: OS {
        return OS(rawValue: osInfo.components(separatedBy: " ").first ?? "") ?? .unknown
    }
    
    var location: URL {
        return Device.devicesDirectory.appendingPathComponent("\(udid)")
    }
    
    var version: String {
        return osInfo.components(separatedBy: " ").last ?? ""
    }
    
    func application(bundleIdentifier: String) -> ApplicationModel? {
        return applications.first(where: { $0.bundleIdentifier == bundleIdentifier })
    }
}
