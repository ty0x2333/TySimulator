//
//  RecentTests.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2017/7/1.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Quick
import Nimble
@testable import TySimulator

class RecentTests: QuickSpec {
    override func spec() {
        describe("LRU", closure: {
            let datas: [Int] = Array(0..<10)
            let capacity = 5
            context("append datas", {
                let lru = LRU<Int, Int>(capacity: capacity)
                for data in datas {
                    lru[data] = 0
                }
                it("count should be equal capacity", closure: {
                    expect(lru.count).to(equal(capacity))
                })
                
                it("data", closure: {
                    expect(lru.datas.map{ $0.key }).to(equal(Array(5..<10).reversed()))
                })
            })
            
            context("get value", {
                let lru = LRU<Int, Int>(capacity: capacity)
                for data in datas {
                    lru[data] = data
                }
                it("value should be equal seted", closure: {
                    for data in 5..<10 {
                        expect(lru[data]).to(equal(data))
                    }
                })
            })
            
            context("change value", {
                let lru = LRU<Int, Int>(capacity: capacity)
                lru[10] = 10
                lru[10] = 20
                it("count", closure: {
                    expect(lru.count).to(equal(1))
                })
                it("value should be changed", closure: {
                    expect(lru[10]).to(equal(20))
                })
            })

        })
        
        describe("LRU-K", closure: {
            let datas: [Int] = Array(0..<10)
            let capacity = 5
            context("append datas", {
                let lruk = LRUK<Int, Int>(capacity: capacity, bufferSize: 10)
                for data in datas {
                    lruk[data] = 0
                }
                it("should be empty", closure: {
                    expect(lruk.count).to(equal(0))
                })
                
                it("has cache", closure: {
                    lruk[0] = 3
                    expect(lruk.count).to(equal(1))
                    expect(lruk[0]).to(equal(3))
                })
            })
        })
    }
}
