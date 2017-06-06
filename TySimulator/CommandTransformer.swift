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
        let transformer = MASDictionaryTransformer()
        guard let value = value as? CommandModel,
            let shortcut = transformer.reverseTransformedValue(value.key) else {
            return [String: Any]()
        }

        return ["id": value.id,"name": value.name, "script": value.script, "shortcut": shortcut]
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? [String: Any] else {
            return nil
        }
        
        let transformer = MASDictionaryTransformer()
        var command: CommandModel
        if let id = value["id"] as? String {
            command = CommandModel(id: id)
        } else {
            command = CommandModel()
        }
        
        command.name = (value["name"] as? String) ?? ""
        if let shortcut = value["shortcut"] as? [String: Any] {
            command.key = transformer.transformedValue(shortcut) as? MASShortcut
        }
        command.script = value["script"] as! String
        
        return command
    }
}
