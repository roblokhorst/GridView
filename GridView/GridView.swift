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

public class GridView: UIView {

  public var columnSpacing: CGFloat = 0 { didSet { updateGrid() } }
  public var numberOfColumns: Int { return columns.count }
  public var numberOfRows: Int { return rows.count }
  public var rowSpacing: CGFloat = 0 { didSet { updateGrid() } }
  public var xPlacement: GridViewXPlacement = .leading { didSet { updateGrid() } }
  public var yPlacement: GridViewYPlacement = .bottom { didSet { updateGrid() } }

  var columns: [GridColumn] = []
  var rows: [GridRow] = []
  var grid: [[GridCell]] = []

  public convenience init(views rows: [[UIView]]) {
    self.init()

    for row in rows {
      addRow(with: row)
    }
  }

  @discardableResult
  public func addColumn(with views: [UIView]) -> GridColumn {
    return insertColumn(at: columns.count, with: views)
  }

  @discardableResult
  public func addRow(with views: [UIView]) -> GridRow {
    return insertRow(at: rows.count, with: views)
  }

  public func cell(for view: UIView) -> GridCell? {
    for row in grid {
      for cell in row {
        if cell.contentView == view {
          return cell
        }
      }
    }

    return nil
  }

  public func column(at index: Int) -> GridColumn {
    return columns[index]
  }

  public func index(of column: GridColumn) -> Int? {
    return columns.index { $0 === column }
  }

  public func index(of row: GridRow) -> Int? {
    return rows.index { $0 === row }
  }

  public func insertColumn(at index: Int, with views: [UIView]) -> GridColumn {
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

    updateGrid() // TODO: Is this the correct place?

    return column
  }

  public func insertRow(at index: Int, with views: [UIView]) -> GridRow {
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

    updateGrid() // TODO: Is this the correct place?

    return row
  }

  public func row(at index: Int) -> GridRow {
    return rows[index]
  }

  public func removeColumn(at index: Int) {
    columns.remove(at: index)
    for (rowIndex, _) in grid.enumerated() {
      grid[rowIndex].remove(at: index)
    }

    // TODO: updateGrid() ?
  }

  public func removeRow(at index: Int) {
    rows.remove(at: index)
    grid.remove(at: index)

    // TODO: updateGrid() ?
  }
}

// MARK: - GridRow

public class GridRow {
  public var bottomPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }
  public var topPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }
  public var yPlacement: GridRowYPlacement = .inherit { didSet { gridView?.updateGrid() } }

  let outerLayoutGuide = UILayoutGuide()
  let innerLayoutGuide = UILayoutGuide()
  var merged: [Range<Int>] = []

  private weak var gridView: GridView?

  init(gridView: GridView) {
    self.gridView = gridView
  }

  public func mergeCells(in range: Range<Int>) {
    merged.append(range)

    // TODO: gridView?.updateGrid() ?
  }
}

// MARK: - GridColumn

public class GridColumn {
  public var leadingPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }
  public var trailingPadding: CGFloat = 0 { didSet { gridView?.updateGrid() } }
  public var xPlacement: GridColumnXPlacement = .inherit { didSet { gridView?.updateGrid() } }

  let outerLayoutGuide = UILayoutGuide()
  let innerLayoutGuide = UILayoutGuide()
  var merged: [Range<Int>] = []

  private weak var gridView: GridView?

  init(gridView: GridView) {
    self.gridView = gridView
  }

  public func mergeCells(in range: Range<Int>) {
    merged.append(range)

    // TODO: gridView?.updateGrid() ?
  }
}

// MARK: - GridCell

public class GridCell {
  public class var emptyContentView: UIView { return _emptyContentView }

  public weak var column: GridColumn?
  public var contentView: UIView?
  public var customPlacementConstraints: [NSLayoutConstraint] = [] { didSet { gridView?.updateGrid() } }
  public weak var row: GridRow?
  public var xPlacement: GridCellXPlacement = .inherit { didSet { gridView?.updateGrid() } }
  public var yPlacement: GridCellYPlacement = .inherit { didSet { gridView?.updateGrid() } }

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
