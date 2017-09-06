//
//  GridView.swift
//  Trein
//
//  Created by Rob Lokhorst on 2017-01-26.
//  Copyright © 2017 Rob Lokhorst. All rights reserved.
//

import UIKit

open class GridView: UIView {

  var columns: [GridColumn] = []
  var rows: [GridRow] = []
  var grid: [[GridCell]] = []

  // MARK: Object lifecycle

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

  // MARK: Position

  open var xPlacement: GridViewXPlacement = .leading { didSet { updateGrid() } }

  open var yPlacement: GridViewYPlacement = .top { didSet { updateGrid() } }

  //open var rowAlignment: GridRow.Alignment = .none { didSet { updateGrid() } }

  // MARK: Spacing

  open var columnSpacing: CGFloat = 6 { didSet { updateGrid() } }

  open var rowSpacing: CGFloat = 6 { didSet { updateGrid() } }

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

  // MARK: Add

  @discardableResult
  open func addColumn(with views: [UIView]) -> GridColumn {
    return insertColumn(at: columns.count, with: views)
  }

  @discardableResult
  open func addRow(with views: [UIView]) -> GridRow {
    return insertRow(at: rows.count, with: views)
  }

  // MARK: Insert

  @discardableResult
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

  @discardableResult
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

  // MARK: Move

  open func moveColumn(at fromIndex: Int, to toIndex: Int) {
    let column = columns.remove(at: fromIndex)
    columns.insert(column, at: toIndex)

    for (rowIndex, _) in grid.enumerated() {
      let cell = grid[rowIndex].remove(at: fromIndex)
      grid[rowIndex].insert(cell, at: toIndex)
    }

    updateGrid()
  }

  open func moveRow(at fromIndex: Int, to toIndex: Int) {
    let row = rows.remove(at: fromIndex)
    rows.insert(row, at: toIndex)

    let cells = grid.remove(at: fromIndex)
    grid.insert(cells, at: toIndex)

    updateGrid()
  }

  // MARK: Remove

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

  // MARK: Merge

  //open func mergeCells(inHorizontalRange hRange: NSRange, verticalRange vRange: NSRange)

}
