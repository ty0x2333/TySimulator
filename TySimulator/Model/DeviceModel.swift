//
//  DeviceModel.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation

enum OS: String {
    case tvOS
    case iOS
    case watchOS
    case unknown
    
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
    
    let os: OS
    let isOpen: Bool
    let isAvailable: Bool
    let version: String
    let hasContent: Bool
    
    let applications: [ApplicationModel]
    let medias: [MediaModel]
    let appGroups: [AppGroupModel]
    let location: URL
    
    init(osInfo: String, json: [String: Any]) {
        name = (json["name"] as? String) ?? ""
        udid = (json["udid"] as? String) ?? ""
        isAvailable = (json["availability"] as? String)?.contains("(available)") ?? false
        isOpen = (json["state"] as? String)?.contains("Booted") ?? false
        self.osInfo = osInfo
        os = OS(rawValue: osInfo.components(separatedBy: " ").first ?? "") ?? .unknown
        version = osInfo.components(separatedBy: " ").last ?? ""
        
        location = Simulator.devicesDirectory.appendingPathComponent("\(udid)")
        applications = Simulator.applications(deviceUDID: udid)
        appGroups = AppGroupModel.groups(location)
        medias = Simulator.medias(path: location)
        hasContent = !applications.isEmpty
    }
    
    func application(bundleIdentifier: String) -> ApplicationModel? {
        return applications.first(where: { $0.bundle.bundleID == bundleIdentifier })
    }
}

extension DeviceModel: Equatable {
    public static func == (lhs: DeviceModel, rhs: DeviceModel) -> Bool {
        return lhs.udid == rhs.udid
    }
}
