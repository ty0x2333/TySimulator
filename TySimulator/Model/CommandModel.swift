//
//  CommandModel.swift
//  TySimulator
//
//  Created by ty0x2333 on 2016/11/18.
//  Copyright © 2016年 ty0x2333. All rights reserved.
//

import Foundation
import MASShortcut

class CommandModel: NSObject {
    private(set) var id: String
    @objc var name: String = ""
    @objc var script: String = ""
    @objc var key: MASShortcut?
    
    convenience override init() {
        let timeStamp = NSDate().timeIntervalSince1970
        self.init(id: String(timeStamp).md5())
    }
    
    @objc init(id: String) {
        self.id = id
        super.init()
    }
    
    override var description: String {
        return "<\(name): \(String(describing: key))>"
    }
}
