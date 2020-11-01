//
//  ResultView.swift
//  Radio
//
//  Created by Alisher on 7/7/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

enum ViewResult {
  case sucess(text: String)
  case failure(text: String)
  case warning(text: String)
  case def(text: String)
}

final class ResulView: UIView {
  @IBOutlet var contentView: UIView! {
    didSet {
      contentView.layer.cornerRadius = 5.0
      contentView.layer.masksToBounds = true
    }
  }
  @IBOutlet weak var titleLabel: UILabel!
  var result: ViewResult = .def(text: "Some Text") {
    didSet {
      updateView()
    }
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecored: NSCoder) {
    super.init(coder: aDecored)
    setupView()
  }
  
  private func setupView() {
    Bundle.main.loadNibNamed("ResultView", owner: self, options: nil)
    addSubview(contentView)
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  private func updateView() {
    switch result {
    case .sucess(let text):
      titleLabel.text = text
      contentView.backgroundColor = UIColor.systemGreen
    case .failure(let text):
      titleLabel.text = text
      contentView.backgroundColor = UIColor.systemRed
    case .warning(let text):
      titleLabel.text = text
      contentView.backgroundColor = UIColor.systemYellow
    case .def(let text):
      titleLabel.text = text
      contentView.backgroundColor = UIColor.systemGray3
    }
  }
}
