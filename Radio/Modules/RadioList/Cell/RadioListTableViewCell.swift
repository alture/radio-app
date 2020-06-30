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
      isPlayingImage.isHidden = !isPlaying
    }
  }
  
  @IBOutlet weak var logoImage: UIImageView!
  @IBOutlet weak var radioTitleLabel: UILabel!
  @IBOutlet weak var isPlayingImage: UIImageView!
  @IBOutlet weak var isFavoriteImage: UIImageView!
  
  private func setupView() {
    guard let radio = radio
    else {
      return
    }
    
    if
      let logoString = radio.logo,
      let logoURL = URL(string: logoString) {
      logoImage.load(url: logoURL)
    } else {
      // TODO: Default Logo
    }
    
    radioTitleLabel.text = radio.name ?? "Station"
    if let radioRate = radio.rate {
      print("Name: \(radio.name!) rate: \(radioRate)")
      isFavoriteImage.isHidden = radioRate == 0
    }
  }
}
