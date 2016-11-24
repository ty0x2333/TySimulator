//
//  CommandTransformer.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/24.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation
import MASShortcut

class CommandTransformer: ValueTransformer {
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        if let value = value as? CommandModel {
            let transformer = MASDictionaryTransformer()
            let shortcut = transformer.reverseTransformedValue(value.key)!
            return ["id": value.id,"name": value.name, "script": value.script, "shortcut": shortcut]
        } else {
            return Dictionary<String, Any>() as Any?
        }
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if let value = value as? Dictionary<String, Any> {
            let transformer = MASDictionaryTransformer()
            var command: CommandModel
            if let id = value["id"] as? String {
                command = CommandModel(id: id)
            } else {
                command = CommandModel()
            }
            
            command.name = value["name"] as! String
            if let shortcut = value["shortcut"] as? Dictionary<String, Any> {
                command.key = transformer.transformedValue(shortcut) as! MASShortcut?
            }
            command.script = value["script"] as! String
            
            return command
        } else {
            return nil
        }
    }
}
