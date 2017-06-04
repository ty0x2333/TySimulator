//
//  FileManager.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation

extension FileManager {
    
    class func directories(_ path: URL) -> [String] {
        let results = try? FileManager.default.contentsOfDirectory(atPath: path.path).filter {
            return isDirectory(path.appendingPathComponent("\($0)").path, name: $0)
        }
        
        return results ?? []
    }
    
    class func isDirectory(_ path: String, name: String) -> Bool {
        var flag = ObjCBool(false)
        FileManager.default.fileExists(atPath: path, isDirectory: &flag)
        
        return flag.boolValue && !name.hasPrefix(".")
    }
}
