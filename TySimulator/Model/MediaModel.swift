//
//  MediaModel.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa

class MediaModel: NSObject {
    
    var name: String = ""
    var location: URL?
    
    class func medias(_ path: URL) -> [MediaModel] {
        let directory = path.appendingPathComponent("/data/Media/DCIM")
        
        return FileManager.directories(directory).map {
            let media = MediaModel()
            media.name = $0
            media.location = directory.appendingPathComponent($0)
            
            return media
        }
    }
    
    func handleMenuItem(_ item: NSMenuItem) {
        guard let location = location else { return }
        NSWorkspace.shared().open(location)
    }
}

