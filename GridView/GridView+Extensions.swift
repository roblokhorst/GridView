//
//  GridView+Extensions.swift
//  GridView
//
//  Created by Rob Lokhorst on 2017-01-26.
//  Copyright © 2017 Rob Lokhorst. All rights reserved.
//

import Foundation

extension GridView {

  var visibleRows: [GridRow] {
    return rows.filter { $0.isHidden == false }
  }

  var visibleColumns: [GridColumn] {
    return columns.filter { $0.isHidden == false }
  }

  func updateGrid() {

    layoutGuides.forEach { removeLayoutGuide($0) }
    subviews.forEach { $0.removeFromSuperview() }

    let gridView = self

    gridView.translatesAutoresizingMaskIntoConstraints = false

    // Row guides
    visibleRows.forEach { row in
      gridView.addLayoutGuide(row.outerLayoutGuide)
      gridView.addLayoutGuide(row.innerLayoutGuide)

      row.innerLayoutGuide.topAnchor.constraint(equalTo: row.outerLayoutGuide.topAnchor, constant: row.topPadding).isActive = true
      row.innerLayoutGuide.bottomAnchor.constraint(equalTo: row.outerLayoutGuide.bottomAnchor, constant: -row.bottomPadding).isActive = true

      if let height = row.height {
        row.innerLayoutGuide.heightAnchor.constraint(equalToConstant: height).isActive = true
      }
    }
    visibleRows.first?.outerLayoutGuide.topAnchor.constraint(equalTo: gridView.topAnchor).isActive = true
    visibleRows.last?.outerLayoutGuide.bottomAnchor.constraint(equalTo: gridView.bottomAnchor).isActive = true
    if visibleRows.count > 1 {
      let verticalSpaces = Array(0..<visibleRows.count - 1).map { _ in UILayoutGuide() }
      for (index, space) in verticalSpaces.enumerated() {
        gridView.addLayoutGuide(space)

        space.heightAnchor.constraint(equalToConstant: rowSpacing).isActive = true

        space.topAnchor.constraint(equalTo: visibleRows[index].outerLayoutGuide.bottomAnchor).isActive = true
        space.bottomAnchor.constraint(equalTo: visibleRows[index + 1].outerLayoutGuide.topAnchor).isActive = true
      }
    }

    // Column guides
    visibleColumns.forEach { column in
      gridView.addLayoutGuide(column.outerLayoutGuide)
      gridView.addLayoutGuide(column.innerLayoutGuide)

      column.innerLayoutGuide.leadingAnchor.constraint(equalTo: column.outerLayoutGuide.leadingAnchor, constant: column.leadingPadding).isActive = true
      column.innerLayoutGuide.trailingAnchor.constraint(equalTo: column.outerLayoutGuide.trailingAnchor, constant: -column.trailingPadding).isActive = true

      if let width = column.width {
        column.innerLayoutGuide.widthAnchor.constraint(equalToConstant: width).isActive = true
      }
    }
    visibleColumns.first?.outerLayoutGuide.leadingAnchor.constraint(equalTo: gridView.leadingAnchor).isActive = true
    visibleColumns.last?.outerLayoutGuide.trailingAnchor.constraint(equalTo: gridView.trailingAnchor).isActive = true
    if visibleColumns.count > 1 {
      let horizontalSpaces = Array(0..<visibleColumns.count - 1).map { _ in UILayoutGuide() }
      for (index, space) in horizontalSpaces.enumerated() {
        gridView.addLayoutGuide(space)

        space.widthAnchor.constraint(equalToConstant: columnSpacing).isActive = true

        space.leadingAnchor.constraint(equalTo: visibleColumns[index].outerLayoutGuide.trailingAnchor).isActive = true
        space.trailingAnchor.constraint(equalTo: visibleColumns[index + 1].outerLayoutGuide.leadingAnchor).isActive = true
      }
    }

    for (rowIndex, row) in rows.enumerated() {
      for (columnIndex, column) in columns.enumerated() {
        if !row.isHidden && !column.isHidden {
          let container = RowColumnContainer(rowIndex: rowIndex, row: row, columnIndex: columnIndex, column: column)
          updateGrid(with: container)
        }
      }
    }
  }

  private func updateGrid(with container: RowColumnContainer) {

    guard !container.isMerged else { return }

    let gridView = self
    let rowIndex = container.rowIndex
    let row = container.row
    let columnIndex = container.columnIndex
    let column = container.column

    let cell = grid[rowIndex][columnIndex]

    guard let contentView = cell.contentView else { return }
    guard contentView != GridCell.emptyContentView else { return }

    gridView.addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false

    // Horizontal guide
    var horizontalGuide = row.innerLayoutGuide

    if let range = column.merged.first(predicate: { $0.lowerBound == rowIndex }) {
      let mergedGuide = UILayoutGuide()
      gridView.addLayoutGuide(mergedGuide)

      let topGuide = horizontalGuide
      let bottomGuide = visibleRows[range.upperBound - 1].innerLayoutGuide

      mergedGuide.topAnchor.constraint(equalTo: topGuide.topAnchor).isActive = true
      mergedGuide.bottomAnchor.constraint(equalTo: bottomGuide.bottomAnchor).isActive = true

      horizontalGuide = mergedGuide
    }

    // Vertical guide
    var verticalGuide = column.innerLayoutGuide

    if let range = row.merged.first(predicate: { $0.lowerBound == columnIndex }) {
      let guide = UILayoutGuide()
      gridView.addLayoutGuide(guide)

      let leadingGuide = verticalGuide
      let trailingGuide = visibleColumns[range.upperBound - 1].innerLayoutGuide

      guide.leadingAnchor.constraint(equalTo: leadingGuide.leadingAnchor).isActive = true
      guide.trailingAnchor.constraint(equalTo: trailingGuide.trailingAnchor).isActive = true

      verticalGuide = guide
    }

    // Horizontal placement
    let xPlacement: GridXPlacement
    switch cell.xPlacement {
    case .leading: xPlacement = .leading
    case .center: xPlacement = .center
    case .trailing: xPlacement = .trailing
    case .fill: xPlacement = .fill
    case .none: xPlacement = .none
    case .inherit:
      switch column.xPlacement {
      case .leading: xPlacement = .leading
      case .center: xPlacement = .center
      case .trailing: xPlacement = .trailing
      case .fill: xPlacement = .fill
      case .none: xPlacement = .none
      case .inherit: xPlacement = gridView.xPlacement
      }
    }

    switch xPlacement {
    case .leading:
      contentView.leadingAnchor.constraint(equalTo: verticalGuide.leadingAnchor).isActive = true
      contentView.trailingAnchor.constraint(lessThanOrEqualTo: verticalGuide.trailingAnchor).isActive = true

    case .center:
      contentView.leadingAnchor.constraint(greaterThanOrEqualTo: verticalGuide.leadingAnchor).isActive = true
      contentView.centerXAnchor.constraint(equalTo: verticalGuide.centerXAnchor).isActive = true
      contentView.trailingAnchor.constraint(lessThanOrEqualTo: verticalGuide.trailingAnchor).isActive = true

    case .trailing:
      contentView.leadingAnchor.constraint(greaterThanOrEqualTo: verticalGuide.leadingAnchor).isActive = true
      contentView.trailingAnchor.constraint(equalTo: verticalGuide.trailingAnchor).isActive = true

    case .fill:
      contentView.leadingAnchor.constraint(equalTo: verticalGuide.leadingAnchor).isActive = true
      contentView.trailingAnchor.constraint(equalTo: verticalGuide.trailingAnchor).isActive = true

    case .none:
      break
    }

    // Vertical placement
    let yPlacement: GridYPlacement
    switch cell.yPlacement {
    case .top: yPlacement = .top
    case .center: yPlacement = .center
    case .bottom: yPlacement = .bottom
    case .fill: yPlacement = .fill
    case .none: yPlacement = .none
    case .inherit:
      switch row.yPlacement {
      case .top: yPlacement = .top
      case .center: yPlacement = .center
      case .bottom: yPlacement = .bottom
      case .fill: yPlacement = .fill
      case .none: yPlacement = .none
      case .inherit: yPlacement = gridView.yPlacement
      }
    }

    switch yPlacement {
    case .top:
      contentView.topAnchor.constraint(equalTo: horizontalGuide.topAnchor).isActive = true
      contentView.bottomAnchor.constraint(lessThanOrEqualTo: horizontalGuide.bottomAnchor).isActive = true

    case .center:
      contentView.topAnchor.constraint(greaterThanOrEqualTo: horizontalGuide.topAnchor).isActive = true
      contentView.centerYAnchor.constraint(equalTo: horizontalGuide.centerYAnchor).isActive = true
      contentView.bottomAnchor.constraint(lessThanOrEqualTo: horizontalGuide.bottomAnchor).isActive = true

    case .bottom:
      contentView.topAnchor.constraint(greaterThanOrEqualTo: horizontalGuide.topAnchor).isActive = true
      contentView.bottomAnchor.constraint(equalTo: horizontalGuide.bottomAnchor).isActive = true

    case .fill:
      contentView.topAnchor.constraint(equalTo: horizontalGuide.topAnchor).isActive = true
      contentView.bottomAnchor.constraint(equalTo: horizontalGuide.bottomAnchor).isActive = true

    case .none:
      break
    }

    // Custom placement
    for constraint in cell.customPlacementConstraints {
      constraint.isActive = true
    }
  }
}

// MARK: - RowColumnContainer

private struct RowColumnContainer {
  let rowIndex: Int
  let row: GridRow
  let columnIndex: Int
  let column: GridColumn

  var isMerged: Bool {

    let mergedRowCells = column.merged
      .map { $0.lowerBound.advanced(by: 1)..<$0.upperBound } // Skip first merged cell, that one will be shown
      .first(predicate: { $0.contains(self.rowIndex) })

    if mergedRowCells != nil { return true }

    let mergedColumnCells = row.merged
      .map { $0.lowerBound.advanced(by: 1)..<$0.upperBound } // Skip first merged cell, that one will be shown
      .first(predicate: { $0.contains(self.columnIndex) })
    
    if mergedColumnCells != nil { return true }
    
    return false
  }
}
