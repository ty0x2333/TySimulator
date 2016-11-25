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
        let command = "${\"device\": \"booted\", \"application\": \"com.tianyiyan.TYTumblr\"}"
        let script = "open \(command)"
        describe("parsing script", closure: {
            it("should be parsed", closure: {
                let result = Process.transformedScript(script)
                expect(result.range(of: command)).to(beNil())
            })
        })
    }
}
