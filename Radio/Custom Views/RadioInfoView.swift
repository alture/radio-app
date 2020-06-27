//
//  RadioInfoView.swift
//  Radio
//
//  Created by Alisher on 6/28/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

protocol RadioInfoViewDelegate {
  func didTapPlayButton()
}

class RadioInfoView: UIView {

  var delegate: RadioInfoViewDelegate?
  
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var playButton: UIButton!
  @IBAction func didTapPlayButton(_ sender: UIButton) {
    delegate?.didTapPlayButton()
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
    Bundle.main.loadNibNamed("RadioInfoView", owner: self, options: nil)
    addSubview(contentView)
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
  }
  
}
