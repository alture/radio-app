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
  
  @objc var radioPlayer = RadioPlayer.shared
  private var observation: NSKeyValueObservation?
  
  private var isPlaying: Bool = false {
    didSet {
      radioTitleLabel.textColor = isPlaying ? #colorLiteral(red: 0.9024619972, green: 0, blue: 0, alpha: 1) : .label
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
  @IBOutlet weak var moreButton: UIButton! {
    didSet {
      moreButton.imageView!.contentMode = .scaleAspectFit
      moreButton.contentVerticalAlignment = .center
      moreButton.contentHorizontalAlignment = .center
    }
  }
  
  @IBAction func didTapMoreButton(_ sender: UIButton) {
    guard let radio = radio else {
      return
    }
    
    didTapMoreButton?(radio)
  }
  
  private func setupView() {
    guard let radio = radio else {
      return
    }
     
    setupObservation()
    isPlaying = radioPlayer.currentRadio == radio
    radioTitleLabel.text = radio.name ?? NSLocalizedString("Название", comment: "Название станций в общем списке")
    if
      let genres = radio.genres {
      let genresNames = genres.map({ $0.name ?? "" })
      radioInfoLabel.text = "\(radio.country?.name ?? NSLocalizedString("Страна", comment: "Отображение стран в общем списке")) • \(genresNames.joined(separator: ", "))"
    } else {
      radioInfoLabel.text = "\(radio.country?.name ?? NSLocalizedString("Страна", comment: "Отображение стран в общем списке"))"
    }
  }
  
  private func setupObservation() {
    observation = radioPlayer.observe(\.currentRadio,
                                      options: .initial,
                                      changeHandler: { [weak self] (player, value) in
                                        self?.isPlaying = player.currentRadio == self?.radio
                                      })
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    isPlaying = selected
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    logoImage.image = UIImage(named: "default-2")
    logoImage.cancelImageLoading()
  }
}
