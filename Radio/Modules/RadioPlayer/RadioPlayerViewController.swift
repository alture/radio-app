//
//  RadioPlayerViewController.swift
//  Radio
//
//  Created by Alisher on 7/11/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import AVFoundation

protocol RadioPlayerViewControllerDelegate {
  func didTapPlayStopButton()
}

final class RadioPlayerViewController: BaseViewController {
  
  // MARK: Properties
  
  var presenter: RadioPlayerPresentation?
  var delegate: RadioPlayerViewControllerDelegate?
  var player: AVPlayer?
  var playerInfo: PlayerInfo?
  
  @IBOutlet weak var volumeSlider: UISlider! {
    didSet {
      volumeSlider.value = player?.volume ?? 0.5
    }
  }
  @IBAction func didChangeSliderValue(_ sender: UISlider) {
    let selectedValue = Float(sender.value)
    player?.volume = selectedValue
  }
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.clipsToBounds = false
      containerView.layer.shadowColor = UIColor.black.cgColor
      containerView.layer.shadowOpacity = 0.1
      containerView.layer.shadowOffset = CGSize.zero
      containerView.layer.shadowRadius = 10
      containerView.layer.cornerRadius = 8.0
      containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds,
                                                    cornerRadius: 8.0).cgPath
    }
  }
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView.layer.cornerRadius = 8.0
      imageView.clipsToBounds = true
    }
  }
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var authorNameLabel: UILabel!
  @IBOutlet weak var playStopButton: UIImageView! {
    didSet {
      let tap = UITapGestureRecognizer(target: self,
                                       action: #selector(didTapPlayStopButton))
      playStopButton.addGestureRecognizer(tap)
    }
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  func configure() {
    guard let playerInfo = playerInfo else {
      return
    }
    
    trackNameLabel.text = playerInfo.title
    authorNameLabel.text = playerInfo.author
    imageView.image = playerInfo.image ?? UIImage(named: "logo")
    playStopButton.image = UIImage(systemName: playerInfo.isPlaying ? "stop.circle" : "play.circle")
  }
  
  @objc private func didTapPlayStopButton() {
    delegate?.didTapPlayStopButton()
    playStopButton.image = UIImage(systemName: playerInfo?.isPlaying ?? false ? "stop.circle" : "play.circle")
  }
}

extension RadioPlayerViewController: RadioPlayerView {
  // TODO: implement view output methods
}
