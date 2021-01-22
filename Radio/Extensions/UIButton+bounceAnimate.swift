//
//  UIView+bounceAnimate.swift
//  Radio
//
//  Created by Alisher on 22.01.2021.
//  Copyright © 2021 Alisher. All rights reserved.
//

import UIKit

extension UIButton {
  func bounceAnimate(to newImage: UIImage? = nil) {
    self.isUserInteractionEnabled = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.isUserInteractionEnabled = true
    }
    
    UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: .allowUserInteraction, animations: {
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        if let image = newImage {
          self.setImage(image, for: .normal)
        }
      }
      
      UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.3) {
        self.transform = .identity
      }
    })
  }
}


