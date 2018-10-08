//
//  ApplicationModel.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class ApplicationBundle {
    let bundleID: String
    let appName: String
    let appIcon: NSImage?
    init(bundleID: String, appName: String, appIcon: NSImage?) {
        self.bundleID = bundleID
        self.appName = appName
        self.appIcon = appIcon
    }
}

class ApplicationModel {
    let bundle: ApplicationBundle
    let uuid: String
    let deviceUDID: String
    
    init?(deviceUDID: String, uuid: String, bundle: ApplicationBundle) {
        self.deviceUDID = deviceUDID
        self.uuid = uuid
        self.bundle = bundle
    }
    
    func loadDataLocation() -> URL? {
        let directory = Simulator.applicationsDataPath(deviceUDID: deviceUDID)
        
        let plist = ".com.apple.mobile_container_manager.metadata.plist"
        for udid in FileManager.directories(directory) {
            let dataPath = directory.appendingPathComponent(udid)
            let plistPath = dataPath.appendingPathComponent(plist)
            guard let json = NSDictionary(contentsOf: plistPath) else {
                continue
            }
            
            let metaDataIdentifier = json["MCMMetadataIdentifier"] as! String
            guard metaDataIdentifier == bundle.bundleID else {
                continue
            }
            
            return dataPath
        }
        return nil
    }
}
