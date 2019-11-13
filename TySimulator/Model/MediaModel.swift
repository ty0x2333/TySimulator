//
//  MediaModel.swift
//  TySimulator
//
//  Created by ty0x2333 on 2016/11/13.
//  Copyright © 2016年 ty0x2333. All rights reserved.
//

import Cocoa

class MediaModel {
    
    let name: String
    let location: URL
    
    init(name: String, location: URL) {
        self.name = name
        self.location = location
    }
}
