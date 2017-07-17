//
//  LRUCache.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2017/7/2.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation

extension Notification.Name {
    public struct LRUCache {
        public static let DidRecord = Notification.Name(rawValue: "com.tianyiyan.notification.lru.didRecord")
    }
}

class LRUCache {
    private let lruk = LRUK<String, String>(capacity: 3, bufferSize: 10, threshold: 2)
    var datas: [String] {
        return lruk.datas.map { $0.value }
    }
    public static let shared = LRUCache()
    
    private init() {
        
    }
    
    func record(app bundleIdentifier: String) {
        lruk[bundleIdentifier] = bundleIdentifier
        NotificationCenter.default.post(name: Notification.Name.LRUCache.DidRecord, object: nil)
    }
    
}
