//
//  UIStackView+AddSubviews.swift
//  Radio
//
//  Created by Alisher on 8/6/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

extension UIStackView {
  func addArrangedSubviews(_ viewes: [UIView]) {
    viewes.forEach { addArrangedSubview($0) }
  }
}
