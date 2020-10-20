//
//  RadioProgressView.swift
//  Radio
//
//  Created by Alisher on 9/13/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class RadioProgressBar: UIView {
  private var isRunningAnimation: Bool = false
  private lazy var progressBarIndicator: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: frame.height))
    view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
    return view
  }()
  
  private var screenSize: CGRect = UIScreen.main.bounds
  override func layoutSubviews() {
    super.layoutSubviews()
    
    addSubview(progressBarIndicator)
  }
  
  func startAnimation() {
    if !isRunningAnimation {
      isRunningAnimation = true
      animate()
    }

  }
  
  func animate() {
    UIView.animateKeyframes(
      withDuration: 1.0,
      delay: 0,
      options: [],
      animations: {
        UIView.addKeyframe(
          withRelativeStartTime: 0.0,
          relativeDuration: 0.5) {
            self.progressBarIndicator.frame = CGRect(
              x: 0,y: 0,
              width: self.frame.width * 0.5, height: self.frame.height)
        }
        
        UIView.addKeyframe(
          withRelativeStartTime: 0.5,
          relativeDuration: 0.5) {
            self.progressBarIndicator.frame = CGRect(
              x: self.frame.width, y: 0,
              width: 0, height: self.frame.height)
        }
    }, completion: { _ in
      self.reset()
      if self.isRunningAnimation {
        self.animate()
      }
    })
  }
  
  func stopAnimation() {
    isRunningAnimation = false
  }
  
  
  private func reset() {
    progressBarIndicator.frame = CGRect(x: 0, y: 0, width: 0, height: frame.height)
  }
  
}
