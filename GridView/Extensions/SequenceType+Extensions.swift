//
//  SequenceType+Extensions.swift
//  GridView
//
//  Created by Rob Lokhorst on 2017-01-26.
//  Copyright © 2017 Rob Lokhorst. All rights reserved.
//

import Foundation

extension Sequence {
  func first(predicate: (Iterator.Element) -> Bool) -> Iterator.Element? {
    for elem in self where predicate(elem) {
      return elem
    }

    return nil
  }
}
