//
//  ApplicationModel.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class ApplicationModel: NSObject {
    var name: String = ""
    var icon: NSImage?
    var bundleIdentifier: String = ""
    var udid: String = ""
    var path: URL?
    
    class func applications(path: URL) -> [ApplicationModel] {
        let directory = path.appendingPathComponent("data/Containers/Bundle/Application")
        return FileManager.directories(directory).map {
            let application = ApplicationModel(path: path, bundleLocation: directory.appendingPathComponent($0))
            return application
        }
    }
    
    init(path: URL, bundleLocation: URL) {
        super.init()
        self.path = path
        self.loadInfo(bundleLocation)
    }
    
    func loadInfo(_ bundleLocation: URL) {
        guard let app = FileManager.directories(bundleLocation).first,
            let json = NSDictionary(contentsOf: bundleLocation.appendingPathComponent("\(app)/Info.plist"))
            else { return }
        
        name = json["CFBundleName"] as! String
        if let bundleIcons = json["CFBundleIcons"] as? [String: Any],
            let primaryIcon = bundleIcons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let iconFile = iconFiles.last {
            
            icon = NSImage(contentsOf: bundleLocation.appendingPathComponent("\(app)/\(iconFile)@3x.png"))
        }
        
        bundleIdentifier = json["CFBundleIdentifier"] as! String
    }
    
    func loadDataLocation() -> URL? {
        guard let path = path else {
            log.warning("can not load application data location, application path is empty.")
            return nil
        }
        let directory = path.appendingPathComponent("data/Containers/Data/Application")
        
        let plist = ".com.apple.mobile_container_manager.metadata.plist"
        for udid in FileManager.directories(directory) {
            let dataPath = directory.appendingPathComponent(udid)
            let plistPath = dataPath.appendingPathComponent(plist)
            guard let json = NSDictionary(contentsOf: plistPath) else {
                continue
            }
            
            let metaDataIdentifier = json["MCMMetadataIdentifier"] as! String
            guard metaDataIdentifier == bundleIdentifier else {
                continue
            }
            
            return dataPath
        }
        return nil
    }
    
    func handleMenuItem(_ item: NSMenuItem) {
        guard let location = loadDataLocation() else {
            log.warning("can not open application data location, it is empty.")
            return
        }
        LRUCache.shared.record(app: self.bundleIdentifier)
        NSWorkspace.shared().open(location)
    }
    
}
