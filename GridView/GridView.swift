//
//  GridView.swift
//  Trein
//
//  Created by Rob Lokhorst on 2017-01-26.
//  Copyright © 2017 Rob Lokhorst. All rights reserved.
//

import UIKit

// TODO: implement all properties and methods
// TODO: order properties and methods in a logical way
// TODO: add all contentViews as subviews before activating customPlacementConstraints
// TODO: updateGrid shouldn't be public
// TODO: fix mergeCells (don't save ranges, but actually merge cells somehow)
// TODO: GridCell .row & .column  get only
// TODO: GridView .index(of:) returns non-optional in NSGridView
// TODO: public or open classes
// TODO: Swift 3 naming convention
// TODO: update defaults to NSGridView defaults (rowSpacing = 6)
// TODO: fix runtime ambiguous position and size
// TODO: make UIView.animate possible, by not using updateGrid()

open class GridView: UIView {

  var columns: [GridColumn] = []
  var rows: [GridRow] = []
  var grid: [[GridCell]] = []

  // MARK: Initializers

  //public convenience init(numberOfColumns columnCount: Int, rows rowCount: Int) { }

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
      let cell = GridCell(gridView: self)
      cell.contentView = views[safe: columnIndex]
      cell.row = row
      cell.column = column

      cells.append(cell)
    }

    grid.insert(cells, at: index)

    updateGrid()
    
    return row
  }

  //open func moveRow(at fromIndex: Int, to toIndex: Int) { }

  open func removeRow(at index: Int) {
    rows.remove(at: index)
    grid.remove(at: index)
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
      let cell = GridCell(gridView: self)
      cell.contentView = views[safe:rowIndex]
      cell.row = row
      cell.column = column

      grid[rowIndex].insert(cell, at: index)
    }

    updateGrid()

    return column
  }

  //open func moveColumn(at fromIndex: Int, to toIndex: Int) { }

  open func removeColumn(at index: Int) {
    columns.remove(at: index)
    for (rowIndex, _) in grid.enumerated() {
      grid[rowIndex].remove(at: index)
    }
  }

  // MARK: Position

  open var xPlacement: GridViewXPlacement = .leading { didSet { updateGrid() } }

  open var yPlacement: GridViewYPlacement = .bottom { didSet { updateGrid() } }

  //open var rowAlignment: GridRowAlignment

  // MARK: Space

  open var columnSpacing: CGFloat = 0 { didSet { updateGrid() } }

  open var rowSpacing: CGFloat = 0 { didSet { updateGrid() } }

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

  //open func cell(at index: Int) -> GridCell

  open var yPlacement: GridRowYPlacement = .inherit { didSet { gridView?.updateGrid() } }

  //open var rowAlignment: GridRowAlignment

  open var height: CGFloat? { didSet { gridView?.updateGrid() } } // Note: NSGridRow uses a non-optional CGFloat.leastNormalMagnitude as default

  open var topPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }

  open var bottomPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }

  //open var isHidden: Bool // Hidden rows/columns will collapse to 0 size and hide all their contentViews.

  open func mergeCells(in range: Range<Int>) {
    merged.append(range)

    // TODO: gridView?.updateGrid() ?
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

  //open func cell(at index: Int) -> GridCell

  open var xPlacement: GridColumnXPlacement = .inherit { didSet { gridView?.updateGrid() } }

  open var width: CGFloat? { didSet { gridView?.updateGrid() } } // Note: NSGridColumn uses a non-optional CGFloat.leastNormalMagnitude as default

  open var leadingPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }

  open var trailingPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }

  //open var isHidden: Bool // Hidden rows/columns will collapse to 0 size and hide all their contentViews.

  open func mergeCells(in range: Range<Int>) {
    merged.append(range)

    // TODO: gridView?.updateGrid() ?
  }
}

// MARK: - GridCell

open class GridCell {
  open class var emptyContentView: UIView { return _emptyContentView }

  open weak var column: GridColumn?
  open var contentView: UIView?
  open var customPlacementConstraints: [NSLayoutConstraint] = [] { didSet { gridView?.updateGrid() } }
  open weak var row: GridRow?
  open var xPlacement: GridCellXPlacement = .inherit { didSet { gridView?.updateGrid() } }
  open var yPlacement: GridCellYPlacement = .inherit { didSet { gridView?.updateGrid() } }

  private weak var gridView: GridView?

  private static var _emptyContentView = UIView()

  init(gridView: GridView) {
    self.gridView = gridView
  }
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
