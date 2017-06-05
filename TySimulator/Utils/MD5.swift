//
//  MD5.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/24.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation

extension String {
    func md5() -> String! {
        let str = cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)

        CC_MD5(str!, strLen, result)

        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }

        result.deinitialize()

        return String(format: hash as String)
    }
}
