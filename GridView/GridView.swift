//
//  GridView.swift
//  Trein
//
//  Created by Rob Lokhorst on 2017-01-26.
//  Copyright © 2017 Rob Lokhorst. All rights reserved.
//

import UIKit

// TODO: implement all properties and methods
// TODO: add all contentViews as subviews before activating customPlacementConstraints
// TODO: fix mergeCells (don't save ranges, but actually merge cells somehow)
// TODO: update defaults to NSGridView defaults
// TODO: fix runtime ambiguous position and size
// TODO: make UIView.animate possible, by not using updateGrid()
// TODO: remove constraint when nilling out .width or .height

open class GridView: UIView {

  var columns: [GridColumn] = []
  var rows: [GridRow] = []
  var grid: [[GridCell]] = []

  // MARK: Initializers

  public convenience init(numberOfColumns columnCount: Int, rows rowCount: Int) {
    self.init()

    for _ in 0..<columnCount { addColumn(with: []) }
    for _ in 0..<rowCount { addRow(with: []) }
  }

  public convenience init(views rows: [[UIView]]) {
    self.init()

    for row in rows {
      addRow(with: row)
    }
  }

  // MARK: Count

  open var numberOfColumns: Int {
    return columns.count
  }

  open var numberOfRows: Int {
    return rows.count
  }

  // MARK: Get

  open func row(at index: Int) -> GridRow {
    return rows[index]
  }

  open func index(of row: GridRow) -> Int? { // Note: NSGridView returns a non-optional Int
    return rows.index { $0 === row }
  }

  open func column(at index: Int) -> GridColumn {
    return columns[index]
  }

  open func index(of column: GridColumn) -> Int? { // Note: NSGridView returns a non-optional Int
    return columns.index { $0 === column }
  }

  open func cell(atColumnIndex columnIndex: Int, rowIndex: Int) -> GridCell {
    return grid[rowIndex][columnIndex]
  }

  open func cell(for view: UIView) -> GridCell? {
    for row in grid {
      for cell in row {
        if cell.contentView == view {
          return cell
        }
      }
    }

    return nil
  }

  // MARK: Add, insert, move and remove

  @discardableResult
  open func addRow(with views: [UIView]) -> GridRow {
    return insertRow(at: rows.count, with: views)
  }

  open func insertRow(at index: Int, with views: [UIView]) -> GridRow {
    for _ in 0..<max(0, views.count - numberOfColumns) {
      addColumn(with: [])
    }

    let row = GridRow(gridView: self)
    rows.insert(row, at: index)

    var cells: [GridCell] = []
    for (columnIndex, column) in columns.enumerated() {
      let cell = GridCell(gridView: self, row: row, column: column)
      cell.contentView = views[safe: columnIndex]

      cells.append(cell)
    }

    grid.insert(cells, at: index)

    updateGrid()
    
    return row
  }

  open func moveRow(at fromIndex: Int, to toIndex: Int) {
    let row = rows.remove(at: fromIndex)
    rows.insert(row, at: toIndex)

    let cells = grid.remove(at: fromIndex)
    grid.insert(cells, at: toIndex)

    updateGrid()
  }

  open func removeRow(at index: Int) {
    rows[index].gridView = nil
    for cell in grid[index] {
      cell._gridView = nil
      cell._row = nil
      cell._column = nil
    }

    rows.remove(at: index)
    grid.remove(at: index)

    updateGrid()
  }

  @discardableResult
  open func addColumn(with views: [UIView]) -> GridColumn {
    return insertColumn(at: columns.count, with: views)
  }

  open func insertColumn(at index: Int, with views: [UIView]) -> GridColumn {
    for _ in 0..<max(0, views.count - numberOfRows) {
      addRow(with: [])
    }

    let column = GridColumn(gridView: self)
    columns.insert(column, at: index)

    for (rowIndex, row) in rows.enumerated() {
      let cell = GridCell(gridView: self, row: row, column: column)
      cell.contentView = views[safe:rowIndex]

      grid[rowIndex].insert(cell, at: index)
    }

    updateGrid()

    return column
  }

  open func moveColumn(at fromIndex: Int, to toIndex: Int) {
    let column = columns.remove(at: fromIndex)
    columns.insert(column, at: toIndex)

    for (rowIndex, _) in grid.enumerated() {
      let cell = grid[rowIndex].remove(at: fromIndex)
      grid[rowIndex].insert(cell, at: toIndex)
    }

    updateGrid()
  }

  open func removeColumn(at index: Int) {
    columns[index].gridView = nil
    for (rowIndex, _) in grid.enumerated() {
      let cell = grid[rowIndex][index]
      cell._gridView = nil
      cell._row = nil
      cell._column = nil
    }

    columns.remove(at: index)
    for (rowIndex, _) in grid.enumerated() {
      grid[rowIndex].remove(at: index)
    }

    updateGrid()
  }

  // MARK: Position

  open var xPlacement: GridViewXPlacement = .leading { didSet { updateGrid() } }

  open var yPlacement: GridViewYPlacement = .bottom { didSet { updateGrid() } }

  //open var rowAlignment: GridRowAlignment

  // MARK: Space

  open var columnSpacing: CGFloat = 6 { didSet { updateGrid() } }

  open var rowSpacing: CGFloat = 6 { didSet { updateGrid() } }

  // MARK: Merge

  //open func mergeCells(inHorizontalRange hRange: NSRange, verticalRange vRange: NSRange)

}

// MARK: - GridRow

open class GridRow {

  let outerLayoutGuide = UILayoutGuide()
  let innerLayoutGuide = UILayoutGuide()
  var merged: [Range<Int>] = []

  init(gridView: GridView) {
    self.gridView = gridView
  }

  open weak var gridView: GridView?

  open var numberOfCells: Int {
    return gridView?.numberOfColumns ?? 0
  }

//  open func cell(at index: Int) -> GridCell {
//    guard let gridView = gridView else {
//      assertionFailure("This row has been deleted, and cannot be used.")
//    }
//  }

  open var yPlacement: GridRowYPlacement = .inherit { didSet { gridView?.updateGrid() } }

  //open var rowAlignment: GridRowAlignment

  open var height: CGFloat? { didSet { gridView?.updateGrid() } } // Note: NSGridRow uses a non-optional CGFloat.leastNormalMagnitude as default

  open var topPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }

  open var bottomPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }

  open var isHidden: Bool = false { didSet { gridView?.updateGrid() } }

  open func mergeCells(in range: Range<Int>) {
    merged.append(range)

    gridView?.updateGrid()
  }
}

// MARK: - GridColumn

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

//  open func cell(at index: Int) -> GridCell {
//    guard let gridView = gridView else {
//      assertionFailure("This column has been deleted, and cannot be used.")
//    }
//  }

  open var xPlacement: GridColumnXPlacement = .inherit { didSet { gridView?.updateGrid() } }

  open var width: CGFloat? { didSet { gridView?.updateGrid() } } // Note: NSGridColumn uses a non-optional CGFloat.leastNormalMagnitude as default

  open var leadingPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }

  open var trailingPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }

  open var isHidden: Bool = false { didSet { gridView?.updateGrid() } }

  open func mergeCells(in range: Range<Int>) {
    merged.append(range)

    gridView?.updateGrid()
  }
}

// MARK: - GridCell

open class GridCell {

  private static var _emptyContentView = UIView()

  fileprivate weak var _gridView: GridView?
  fileprivate weak var _row: GridRow?
  fileprivate weak var _column: GridColumn?

  // MARK: Init

  init(gridView: GridView, row: GridRow, column: GridColumn) {
    self._gridView = gridView
    self._row = row
    self._column = column
  }

  // MARK: Getters

  open var contentView: UIView?

  open class var emptyContentView: UIView { return _emptyContentView }

  open weak var row: GridRow? {
    return _row
  }

  open weak var column: GridColumn? {
    return _column
  }

  // MARK: Position

  open var xPlacement: GridCellXPlacement = .inherit { didSet { _gridView?.updateGrid() } }

  open var yPlacement: GridCellYPlacement = .inherit { didSet { _gridView?.updateGrid() } }

  //open var rowAlignment: NSGridRowAlignment

  open var customPlacementConstraints: [NSLayoutConstraint] = [] { didSet { _gridView?.updateGrid() } }
}

// MARK: - GridCellXPlacement

public enum GridXPlacement {
  case leading
  case center
  case trailing
  case fill
  case none
}

public enum GridXPlacementWithInherit {
  case leading
  case center
  case trailing
  case fill
  case none
  case inherit
}

public typealias GridViewXPlacement = GridXPlacement
public typealias GridColumnXPlacement = GridXPlacementWithInherit
public typealias GridCellXPlacement = GridXPlacementWithInherit

// MARK: - GridCellYPlacement

public enum GridYPlacement {
  case top
  case center
  case bottom
  case fill
  case none
}

public enum GridYPlacementWithInherit {
  case top
  case center
  case bottom
  case fill
  case none
  case inherit
}

public typealias GridViewYPlacement = GridYPlacement
public typealias GridRowYPlacement = GridYPlacementWithInherit
public typealias GridCellYPlacement = GridYPlacementWithInherit
