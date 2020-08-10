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
  
  @IBOutlet weak var logoImage: UIImageView! {
    didSet {
      logoImage.layer.cornerRadius = 5.0
      logoImage.clipsToBounds = true
    }
  }
  @IBOutlet weak var radioTitleLabel: UILabel!
  @IBOutlet weak var radioInfoLabel: UILabel!
  @IBOutlet weak var isPlayingImage: UIImageView! {
    didSet {
      isPlayingImage.layer.cornerRadius = 5.0
      isPlayingImage.clipsToBounds = true
    }
  }
  @IBOutlet weak var moreButton: UIImageView! {
    didSet {
      let tap = UITapGestureRecognizer(target: self, action: #selector(didTapFavoriteImage(_:)))
      moreButton.addGestureRecognizer(tap)
    }
  }
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.clipsToBounds = false
      containerView.layer.shadowColor = UIColor.black.cgColor
      containerView.layer.shadowOpacity = 0.1
      containerView.layer.shadowOffset = CGSize.zero
      containerView.layer.shadowRadius = 5.0
      containerView.layer.cornerRadius = 5.0
      containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds,
                                                    cornerRadius: 5.0).cgPath
    }
  }
  
  private func setupView() {
    guard let radio = radio else {
      return
    }
    
    if let logoString = radio.logo{
      logoImage.load(logoString)
    } else {
      logoImage.image = UIImage(named: "default-2")
    }
    
    radioTitleLabel.text = radio.name ?? "Название"
    if
      let genres = radio.genres {
      let genresNames = genres.map({ $0.name ?? "" })
      radioInfoLabel.text = "\(radio.country?.name ?? "Страна") • \(genresNames.joined(separator: ", "))"
    } else {
      radioInfoLabel.text = "\(radio.country?.name ?? "Страна")"
    }
    


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
