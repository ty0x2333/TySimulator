//
//  ApplicationModel.swift
//  TySimulator
//
//  Created by ty0x2333 on 2016/11/13.
//  Copyright © 2016年 ty0x2333. All rights reserved.
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
    let dataPath: URL
    
    init?(deviceUDID: String, uuid: String, bundle: ApplicationBundle, dataPath: URL) {
        self.deviceUDID = deviceUDID
        self.uuid = uuid
        self.bundle = bundle
        self.dataPath = dataPath
    }
}
