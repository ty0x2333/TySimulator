//
//  LRUK.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2017/7/1.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation

class LRUK<K: Hashable, V> {
    private let cache: LRU<K, V>
    private let bufferSize: Int
    let history: LRU<K, (hits: Int, value: V)>
    private let threshold: Int
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public var count: Int {
        return cache.count
    }
    
    public var datas: [(key: K, value: V)] {
        return cache.datas
    }
    
    init(capacity: Int, bufferSize: Int, threshold: Int = 2, datas: [(key: K, value: V)]? = nil, history: [(key: K, value: (hits: Int, value: V))]? = nil) {
        cache = LRU<K, V>(capacity: capacity, datas: datas)
        self.history = LRU<K, (hits: Int, value: V)>(capacity: bufferSize, datas: history)
        self.bufferSize = bufferSize
        self.threshold = threshold
    }
    
    subscript (key: K) -> V? {
        get {
            return cache[key]
        }
        
        // if value is nil, it will do nothing
        set(value) {
            guard let newValue = value else {
                return
            }
            _ = semaphore.wait(timeout: .distantFuture)
            
            if let his = history[key] {
                let hits = his.hits + 1
                
                if hits < threshold {
                    history[key] = (hits: hits, value: newValue)
                } else {
                    history[key] = nil
                    cache[key] = newValue
                }
            } else if threshold < 2 {
                cache[key] = newValue
            } else {
                history[key] = (hits: 1, value: newValue)
            }
            
            semaphore.signal()
        }
    }
}
