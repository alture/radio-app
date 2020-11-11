//
//  UITableView+Deselect.swift
//  Radio
//
//  Created by Alisher on 11/6/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
extension UITableView {
  func deselectRows(at section: Int) {
    if let selectedRows = indexPathsForSelectedRows?.filter({ $0.section == section }) {
      selectedRows.forEach {
        deselectRow(at: $0, animated: false)
      }
    }
  }
}
