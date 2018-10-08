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
    
    @objc func handleMenuItem(_ item: NSMenuItem) {
        guard let location = location else { return }
        NSWorkspace.shared.open(location)
    }
}
