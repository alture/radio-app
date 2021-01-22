//
//  RadioInfoView.swift
//  Radio
//
//  Created by Alisher on 6/28/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import SDWebImage

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
      
      titleLabel.text = track.trackName
      logoImageView.image = UIImage(named: "default-2")
      if
        let trackCover = track.trackCover,
        let url = URL(string: trackCover){
        logoImageView.sd_setImage(with: url)
        UIView.animate(
          withDuration: 0.1,
          delay: 0,
          options: [],
          animations:  {
            self.isHidden = false
            self.alpha = 1.0
          }) { (_) in
          self.playButton.isUserInteractionEnabled = true
        }
      }
      
    }
  }
  var delegate: RadioInfoViewDelegate?
  var isPlaying: Bool = false {
    didSet {
      DispatchQueue.main.async {
        self.playButton.setImage(UIImage(systemName: self.isPlaying
          ? "stop.fill"
          : "play.fill" ),
                            for: .normal)
      }

    }
  }
  
  var isLoading: Bool = false {
    didSet {
      if isLoading {
        progressViewHeight.constant = 2.0
        UIView.animate(
          withDuration: 0.2) {
          self.layoutIfNeeded()
        } completion: { (_) in
          self.progressBarView.startAnimation()
        }
      } else {
        self.progressBarView.stopAnimation()
      }
    }
  }
  
  @IBOutlet weak var progressBarView: RadioProgressBar! {
    didSet {
      progressBarView.alpha = 0.5
      
      progressBarView.completion = { [weak self] in
        self?.progressViewHeight.constant = 2.0
        UIView.animate(withDuration: 0.6) {
          self?.layoutIfNeeded()
        }
      }
    }
  }
  @IBOutlet weak var progressViewHeight: NSLayoutConstraint!
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
    let currentImageName = isPlaying ? "stop.fill" : "play.fill"
    sender.bounceAnimate(to: UIImage(systemName: currentImageName))
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
