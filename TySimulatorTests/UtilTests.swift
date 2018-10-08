//
//  UtilTests.swift
//  TySimulatorTests
//
//  Created by luckytianyiyan on 2018/10/8.
//  Copyright © 2018 luckytianyiyan. All rights reserved.
//

import Quick
import Nimble
@testable import TySimulator

class UtilTests: QuickSpec {
    override func spec() {
        describe("URL", closure: {
            context("removeTrailingSlash", {
                let result = "https://tyy.sh"
                it("removed trailing slash", closure: {
                    expect(URL(string: "https://tyy.sh/")?.removeTrailingSlash?.absoluteString).to(equal(result))
                })
                
                it("do nothing", closure: {
                    expect(URL(string: "https://tyy.sh")?.removeTrailingSlash?.absoluteString).to(equal(result))
                })
            })
        })
        
        describe("String", closure: {
            context("md5", {
                it("had generated", closure: {
                    expect("https://tyy.sh".md5()).to(equal("651949dc4ffadf4d933ac565796de4cd"))
                })
            })
        })
    }
}
