//
//  URL+Extension.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Foundation

extension URL {

  var removeTrailingSlash: URL {
    guard absoluteString.hasSuffix("/") else { return self }

    let string = absoluteString.substring(to: absoluteString.characters.index(before: absoluteString.endIndex))
    return URL(string: string)!
  }
}
