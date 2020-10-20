//
//  UIImageView+LoadImg.swift
//  Radio
//
//  Created by Alisher on 6/28/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
private var imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
  func load(_ urlString: String) {    
    if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
      self.image = cacheImage
      return
    }
    
    guard let url = URL(string: urlString) else {
      return
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print("Couldn't download image: ", error)
        return
      }
      
      guard let data = data else { return }
      let image = UIImage(data: data)
      imageCache.setObject(data as AnyObject,
                           forKey: urlString as AnyObject)
      DispatchQueue.main.async {
        self.image = image
      }
    }.resume()
  }
}
