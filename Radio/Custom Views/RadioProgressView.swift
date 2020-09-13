//
//  RadioProgressView.swift
//  Radio
//
//  Created by Alisher on 9/13/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class RadioProgressBar: UIView {
  private lazy var progressViewIndicator: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: frame.height))
    view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    addSubview(progressViewIndicator)
  }
  
}
