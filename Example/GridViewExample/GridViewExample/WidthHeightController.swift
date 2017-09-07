//
//  WidthHeightController.swift
//  GridViewExample
//
//  Created by Rob Lokhorst on 2017-02-08.
//  Copyright © 2017 Rob Lokhorst. All rights reserved.
//

import GridView
import UIKit

class WidthHeightController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "Width and height"
    view.backgroundColor = .white

    let gridView = GridView(views: createViews())
    gridView.row(at: 0).height = 25
    gridView.row(at: 3).height = 25
    gridView.column(at: 0).width = 25
    gridView.column(at: 3).width = 25

    view.addSubview(gridView)
    gridView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    gridView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }

  private func createViews() -> [[UIView]] {
    let colors: [[UIColor]] = [
      [.red, .green, .yellow, .blue],
      [.blue, .red, .green, .yellow],
      [.yellow, .blue, .red, .green],
      [.green, .yellow, .blue, .red]
    ]

    return colors.map { $0.map { CustomView(backgroundColor: $0) } }
  }
}

private class CustomView: UIView {
  init(backgroundColor: UIColor) {
    super.init(frame: .zero)

    self.backgroundColor = backgroundColor
    self.widthAnchor.constraint(equalToConstant: 50).isActive = true
    self.heightAnchor.constraint(equalToConstant: 50).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
