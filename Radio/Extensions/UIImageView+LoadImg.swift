//
//  UIImageView+LoadImg.swift
//  Radio
//
//  Created by Alisher on 6/28/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
private var imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
  func load(_ urlString: String) {
    let itemString = NSString(string: urlString)
    if let cacheImage = imageCache.object(forKey: itemString) {
      self.image = cacheImage
      return
    }
    
    guard let url = URL(string: urlString) else {
      return
    }
    
    DispatchQueue.global().async { [weak self] in
      guard
        let data = try? Data(contentsOf: url),
        let image = UIImage(data: data)
      else {
        return
      }
      
      imageCache.setObject(image, forKey: itemString)
      DispatchQueue.main.async {
        self?.image = image
      }
    }
  }
}
