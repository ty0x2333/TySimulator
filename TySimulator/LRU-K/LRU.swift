//
//  LRU.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2017/7/1.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation

class LRU<K: Hashable, V> {
    private let capacity: Int
    fileprivate var list = [K]()
    fileprivate var hashtable: [K: V]
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public var count: Int {
        return list.count
    }
    
    public var datas: [(key: K, value: V)] {
        var results: [(key: K, value: V)] = []
        for key in list.reversed() {
            if let value = hashtable[key] {
                results.append((key: key, value: value))
            }
        }
        return results
    }
    
    init(capacity: Int) {
        self.capacity = capacity
        hashtable = [K: V](minimumCapacity: capacity)
    }
    
    subscript (key: K) -> V? {
        get {
            _ = semaphore.wait(timeout: .distantFuture)
            guard let elem = hashtable[key] else {
                semaphore.signal()
                return nil
            }
            list.remove(at: list.index(of: key)!)
            list.append(key)
            semaphore.signal()
            return elem
        }
        
        set(value) {
            _ = semaphore.wait(timeout: .distantFuture)
            repeat {
                if hashtable[key] != nil {
                    list.remove(at: list.index(of: key)!)
                }
                
                hashtable[key] = value
                
                if value == nil {
                    break
                }
                
                list.append(key)
                
                if list.count > capacity {
                    let deletedKey = list.removeFirst()
                    hashtable.removeValue(forKey: deletedKey)
                }
            } while false
            
            semaphore.signal()
        }
    }
}
