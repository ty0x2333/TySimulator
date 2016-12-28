//
//  ScriptTests.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/25.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Quick
import Nimble
@testable import TySimulator

class ScriptTests: QuickSpec {
    override func spec() {
        describe("parsing script", closure: {
            context("input valid command", {
                let command = "${{\"device\": \"booted\", \"application\": \"com.tianyiyan.TYTumblr\"}}"
                let script = "open \(command)"
                it("should be parsed", closure: {
                    expect { try Script.transformedScript(script) }.toNot(throwError())
                })
            })
            
            context("input not valid command", {
                let command = "${{xxxx}}"
                let script = "open \(command)"
                it("should be parsed", closure: {
                    expect { try Script.transformedScript(script) }.to(throwError())
                })
            })
        })
    }
}
