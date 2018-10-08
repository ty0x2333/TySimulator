//
//  AppGroupModel.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class AppGroupModel: NSObject {
    
    var bundleIdentifier: String = ""
    var location: URL?
    
    // MARK: - Load
    
    class func groups(_ path: URL) -> [AppGroupModel] {
        let directory = path.appendingPathComponent("/data/Containers/Shared/AppGroup")
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
    
    @objc func handleMenuItem(_ item: NSMenuItem) {
        guard let location = location else { return }
        NSWorkspace.shared.open(location)
    }
}
