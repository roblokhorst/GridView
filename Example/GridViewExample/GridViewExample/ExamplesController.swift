//
//  ExamplesController.swift
//  GridViewExample
//
//  Created by Rob Lokhorst on 2017-02-08.
//  Copyright © 2017 Rob Lokhorst. All rights reserved.
//

import UIKit

class ExamplesController: UITableViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
    cell.textLabel?.text = "Width and height"

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    navigationController?.pushViewController(WidthHeightController(), animated: true)
  }
}
