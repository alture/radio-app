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
  func showPlayer()
}

class RadioInfoView: UIView {
  
  var track: Track? {
    didSet {
      guard let track = track else {
        return
      }
      
      logoImageView.cancelImageLoading()
      titleLabel.text = track.trackName
      logoImageView.image = UIImage(named: "default-2")
      if
        let trackCover = track.trackCover,
        let url = URL(string: trackCover){
        logoImageView.loadImage(at: url)
      }
      
      playButton.isUserInteractionEnabled = true
    }
  }
  var delegate: RadioInfoViewDelegate?
  var isPlaying: Bool = false {
    didSet {      
      playButton.setImage(UIImage(systemName: isPlaying
        ? "stop.fill"
        : "play.fill" ),
                          for: .normal)
    }
  }
  
  var isLoading: Bool = false {
    didSet {
      if isLoading {
        progressBarView.startAnimation()
      } else {
        progressBarView.stopAnimation()
      }
    }
  }
  
  @IBOutlet weak var progressBarView: RadioProgressBar!
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var logoImageView: UIImageView! {
    didSet {
      logoImageView.layer.cornerRadius = 5.0
      logoImageView.layer.masksToBounds = true
      logoImageView.backgroundColor = .white
    }
  }
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var playButton: UIButton! {
    didSet {
      playButton.isUserInteractionEnabled = false
    }
  }
  @IBAction func didTapPlayButton(_ sender: UIButton) {
    delegate?.didTapPlayButton()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSelf))
    isUserInteractionEnabled = true
    addGestureRecognizer(tap)
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
  
  @objc private func didTapSelf() {
    delegate?.showPlayer()
  }
  
}
