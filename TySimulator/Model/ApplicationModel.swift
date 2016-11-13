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
    
    lazy var location: URL? = self.loadDataLocation()
    
    static func load(path: URL) -> [ApplicationModel] {
        let directory = path.appendingPathComponent("data/Containers/Bundle/Application")
        return self.directories(directory).map {
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
        guard let app = ApplicationModel.directories(bundleLocation).first,
            let json = NSDictionary(contentsOf: bundleLocation.appendingPathComponent("\(app)/Info.plist"))
            else { return }
        
        name = json["CFBundleName"] as! String
        bundleIdentifier = json["CFBundleIdentifier"] as! String
    }
    
    func loadDataLocation() -> URL? {
        guard let path = path else { return nil }
        let directory = path.appendingPathComponent("data/Containers/Data/Application")
        
        let plist = ".com.apple.mobile_container_manager.metadata.plist"
        for udid in ApplicationModel.directories(directory) {
            let dataPath = directory.appendingPathComponent(udid)
            let plistPath = dataPath.appendingPathComponent(plist)
            guard let json = NSDictionary(contentsOf: plistPath)
                else { continue }
            
            let metaDataIdentifier = json["MCMMetadataIdentifier"] as! String
            guard metaDataIdentifier == bundleIdentifier else { continue }
            
            return dataPath
        }
        return nil
    }
    
    func handleMenuItem(_ item: NSMenuItem) {
        guard let location = location else { return }
        NSWorkspace.shared().open(location)
    }
    
    // MARK: Helper
    static func directories(_ path: URL) -> [String] {
        let results = try? FileManager.default.contentsOfDirectory(atPath: path.path).filter {
            return isDirectory(path.appendingPathComponent("\($0)").path, name: $0)
        }
        
        return results ?? []
    }
    
    static func isDirectory(_ path: String, name: String) -> Bool {
        var flag = ObjCBool(false)
        FileManager.default.fileExists(atPath: path, isDirectory: &flag)
        
        return flag.boolValue && !name.hasPrefix(".")
    }
}
