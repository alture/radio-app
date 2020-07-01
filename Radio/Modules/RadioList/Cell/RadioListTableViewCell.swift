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
  
  var isFavorite: Bool = false {
    didSet {
      let imageName = isFavorite ? "star.fill" : "star"
      isFavoriteImage.image = UIImage(systemName: imageName)
    }
  }
  
  var didTapFavoriteButton: (() -> Void)?
  
  @IBOutlet weak var logoImage: UIImageView!
  @IBOutlet weak var radioTitleLabel: UILabel!
  @IBOutlet weak var isPlayingImage: UIImageView!
  @IBOutlet weak var isFavoriteImage: UIImageView! {
    didSet {
      let tap = UITapGestureRecognizer(target: self, action: #selector(didTapFavoriteImage(_:)))
      isFavoriteImage.addGestureRecognizer(tap)
    }
  }
  
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
      isFavorite = radioRate > 0
    }
  }
  
  @objc private func didTapFavoriteImage(_ sender: UITapGestureRecognizer) {
    if sender.state == .ended {
      isFavorite = !isFavorite
      didTapFavoriteButton?()
    }
  }
}
