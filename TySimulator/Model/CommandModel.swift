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
    var name: String = ""
    var script: String = ""
    var key: MASShortcut?
    
    override var description: String {
        get {
            return "<\(self.name): \(self.key)>"
        }
    }
}
