//
//  GridCell.swift
//  GridView
//
//  Created by Rob Lokhorst on 2017-09-06.
//  Copyright © 2017 Rob Lokhorst. All rights reserved.
//

import Foundation

open class GridCell {

  private static var _emptyContentView = UIView()

  weak var _gridView: GridView?
  weak var _row: GridRow?
  weak var _column: GridColumn?

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

  open var xPlacement: GridCellXPlacement = .inherited { didSet { _gridView?.updateGrid() } }

  open var yPlacement: GridCellYPlacement = .inherited { didSet { _gridView?.updateGrid() } }

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

public enum GridXPlacementWithInherited {
  case leading
  case center
  case trailing
  case fill
  case none
  case inherited
}

public typealias GridViewXPlacement = GridXPlacement
public typealias GridColumnXPlacement = GridXPlacementWithInherited
public typealias GridCellXPlacement = GridXPlacementWithInherited

// MARK: - GridCellYPlacement

public enum GridYPlacement {
  case top
  case center
  case bottom
  case fill
  case none
}

public enum GridYPlacementWithInherited {
  case top
  case center
  case bottom
  case fill
  case none
  case inherited
}

public typealias GridViewYPlacement = GridYPlacement
public typealias GridRowYPlacement = GridYPlacementWithInherited
public typealias GridCellYPlacement = GridYPlacementWithInherited
