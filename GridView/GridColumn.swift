//
//  GridColumn.swift
//  GridView
//
//  Created by Rob Lokhorst on 2017-09-06.
//  Copyright © 2017 Rob Lokhorst. All rights reserved.
//

import Foundation

open class GridColumn {

  let outerLayoutGuide = UILayoutGuide()
  let innerLayoutGuide = UILayoutGuide()
  var merged: [Range<Int>] = []

  init(gridView: GridView) {
    self.gridView = gridView
  }

  open weak var gridView: GridView?

  open var numberOfCells: Int {
    return gridView?.numberOfRows ?? 0
  }

  open func cell(at index: Int) -> GridCell? { // Note: NSGridColumn returns a non-optional GridCell
    guard let gridView = gridView, let columnIndex = gridView.index(of: self) else {
      print("Assertion failure in GridColumn.cell(at:). This column has been deleted, and cannot be used.")
      return nil
    }

    return gridView.cell(atColumnIndex: columnIndex, rowIndex: index)
  }

  open var xPlacement: GridColumnXPlacement = .inherited { didSet { gridView?.updateGrid() } }

  open var width: CGFloat? { didSet { gridView?.updateGrid() } } // Note: NSGridColumn uses a non-optional CGFloat.leastNormalMagnitude as default

  open var leadingPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }

  open var trailingPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }

  open var isHidden: Bool = false { didSet { gridView?.updateGrid() } }

  open func mergeCells(in range: Range<Int>) {
    merged.append(range)

    gridView?.updateGrid()
  }
}
