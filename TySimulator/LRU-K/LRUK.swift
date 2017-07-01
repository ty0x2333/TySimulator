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
    private let history: LRU<K, (hits: Int, value: V)>
    private let threshold: Int
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public var count: Int {
        return cache.count
    }
    
    
    init(capacity: Int, bufferSize: Int, threshold: Int = 2) {
        cache = LRU<K, V>(capacity: capacity)
        history = LRU<K, (hits: Int, value: V)>(capacity: bufferSize)
        self.bufferSize = bufferSize
        self.threshold = threshold
    }
    
    subscript (key: K) -> V? {
        get {
            return cache[key]
        }
        
        // if value is nil, it will do nothing
        set(value) {
            guard let v = value else {
                return
            }
            _ = semaphore.wait(timeout: .distantFuture)
            
            if let his = history[key] {
                let hits = his.hits + 1
                
                if hits < threshold {
                    history[key] = (hits: hits, value: v)
                } else {
                    history[key] = nil
                    cache[key] = v
                }
            } else if threshold < 2 {
                cache[key] = v
            } else {
                history[key] = (hits: 1, value: v)
            }
            
            semaphore.signal()
        }
    }
}
