//
//  LRUCache.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2017/7/2.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Notification.Name {
    public struct LRUCache {
        public static let DidRecord = Notification.Name(rawValue: "com.tianyiyan.notification.lru.didRecord")
    }
}

class LRUCache {
    fileprivate var lruk: LRUK<String, String>
    var datas: [String] {
        return lruk.datas.map { $0.value }
    }
    public static let shared = LRUCache(file: LRUCache.filePath)
    
    fileprivate init() {
        lruk = LRUK<String, String>(capacity: 5, bufferSize: 10, threshold: 2)
    }
    
    func record(app bundleIdentifier: String) {
        lruk[bundleIdentifier] = bundleIdentifier
        NotificationCenter.default.post(name: Notification.Name.LRUCache.DidRecord, object: nil)
    }
}

extension LRUCache {
    static var filePath: URL {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier!
        return appSupportURL.appendingPathComponent(bundleID, isDirectory: true).appendingPathComponent("LRUCache.json")
    }
    
    func jsonDescription() -> JSON {
        let history = lruk.history.datas.map { ["hits": $0.value.hits, "bundle_id": $0.value.value] }
        let datas = lruk.datas.map { $0.value }
        
        return JSON(["datas": datas, "history": history])
    }
    
    convenience init(json: JSON) {
        self.init()
        let datas = json["datas"].arrayValue.map { (key: $0.stringValue, value: $0.stringValue) }
        let history = json["history"].arrayValue.map {
            (key: $0["bundle_id"].stringValue, value: (hits: $0["hits"].intValue, value: $0["bundle_id"].stringValue))
        }
        lruk = LRUK<String, String>(capacity: 3, bufferSize: 10, threshold: 2, datas: datas, history: history)
    }
    
    convenience init(file: URL) {
        if let content = try? String(contentsOf: LRUCache.filePath, encoding: .utf8) {
            self.init(json: JSON(parseJSON: content))
        } else {
            self.init()
        }
    }
    
    func save() {
        do {
            try jsonDescription().rawString([.castNilToNSNull: true])?.write(to: LRUCache.filePath, atomically: true, encoding: .utf8)
            log.info("save LRU cache to \(LRUCache.filePath)")
        } catch {
            log.error("save LRU cache error: \(error)")
        }
    }
}
