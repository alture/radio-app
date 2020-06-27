//
//  RadioListTableViewCell.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class RadioListTableViewCell: UITableViewCell {
  
  var radio: Radio? {
    didSet {
      setupView()
    }
  }
  
  var isPlaying: Bool = false {
    didSet {
      logoImage.isHidden = !isPlaying
    }
  }
  
  @IBOutlet weak var logoImage: UIImageView!
  @IBOutlet weak var radioTitleLabel: UILabel!
  @IBOutlet weak var isPlayingImage: UIImageView!
    
  private func setupView() {
    guard let radio = radio
    else {
      return
    }
    
    if
      let logoString = radio.logo,
      let logoURL = URL(string: logoString),
      let data = try? Data(contentsOf: logoURL) {
      logoImage.image = UIImage(data: data)
    } else {
      // TODO: Default Logo
    }
    
    radioTitleLabel.text = radio.name ?? "Station"
  }
}
