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
  
  var didTapMoreButton: ((_ radio: Radio) -> Void)?
  
  @IBOutlet weak var logoImage: UIImageView!
  @IBOutlet weak var radioTitleLabel: UILabel!
  @IBOutlet weak var isPlayingImage: UIImageView! {
    didSet {
      isPlayingImage.layer.cornerRadius = 5.0
    }
  }
  @IBOutlet weak var moreButton: UIImageView! {
    didSet {
      let tap = UITapGestureRecognizer(target: self, action: #selector(didTapFavoriteImage(_:)))
      moreButton.addGestureRecognizer(tap)
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
      // TODO: Default App Image
    }
    
    radioTitleLabel.text = radio.name ?? "Station"
  }
  
  @objc private func didTapFavoriteImage(_ sender: UITapGestureRecognizer) {
    if sender.state == .ended {
      guard let radio = radio else {
        return
      }
      
      didTapMoreButton?(radio)
    }
  }
}
