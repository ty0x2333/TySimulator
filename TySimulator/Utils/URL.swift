//
//  URL.swift
//  TySimulator
//
//  Created by ty0x2333 on 2016/11/13.
//  Copyright © 2016年 ty0x2333. All rights reserved.
//

import Foundation

extension URL {
  var removeTrailingSlash: URL? {
    guard absoluteString.hasSuffix("/") else {
        return self
    }
    var urlString = absoluteString
    urlString.removeLast()
    return URL(string: urlString)
  }
}
