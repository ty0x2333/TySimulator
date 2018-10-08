//
//  URL.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
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
