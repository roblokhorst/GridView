//
//  Array+Extensions.swift
//  GridView
//
//  Created by Rob Lokhorst on 2017-01-26.
//  Copyright © 2017 Rob Lokhorst. All rights reserved.
//

import Foundation

extension Array {
  subscript (safe index: Int) -> Element? {
    return indices ~= index ? self[index] : nil
  }
}
