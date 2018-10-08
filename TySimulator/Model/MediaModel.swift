//
//  MediaModel.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class MediaModel {
    
    let name: String
    let location: URL
    
    init(name: String, location: URL) {
        self.name = name
        self.location = location
    }
    
    @objc func handleMenuItem(_ item: NSMenuItem) {
        NSWorkspace.shared.open(location)
    }
}
