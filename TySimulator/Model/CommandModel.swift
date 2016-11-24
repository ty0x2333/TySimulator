//
//  CommandModel.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/18.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation
import MASShortcut

class CommandModel: NSObject {
    private(set) var id: String
    var name: String = ""
    var script: String = ""
    var key: MASShortcut?
    
    convenience override init() {
        let timeStamp = NSDate().timeIntervalSince1970
        self.init(id: String(timeStamp).md5())
    }
    
    init(id: String) {
        self.id = id
        super.init()
    }
    
    override var description: String {
        get {
            return "<\(self.name): \(self.key)>"
        }
    }
}
