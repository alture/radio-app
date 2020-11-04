//
//  ImageLoader.swift
//  Radio
//
//  Created by Alisher on 10/23/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit


final class ImageLoader {
  private var imageCache = NSCache<NSURL, UIImage>()
  private var runningRequests = [UUID: URLSessionDataTask]()
  
  func loadImage(_ url: NSURL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
    if let cachedImage = imageCache.object(forKey: url) {
      completion(.success(cachedImage))
      return nil
    }
    
    let uuid = UUID()
    let task = URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
      
      defer { self.runningRequests.removeValue(forKey: uuid) }
      
      if let data = data,
         let image = UIImage(data: data) {
        self.imageCache.setObject(image, forKey: url)
        completion(.success(image))
        return
      }
      
      guard let error = error else {
        return
      }
      
      guard (error as NSError).code == NSURLErrorCancelled else {
        completion(.failure(error))
        return
      }
    }
    task.resume()
    runningRequests[uuid] = task
    return uuid
  }
  
  func cancelLoad(_ uuid: UUID) {
    runningRequests[uuid]?.cancel()
    runningRequests.removeValue(forKey: uuid)
  }
}

final class UIImageLoader {
  static let shared = UIImageLoader()
  
  private lazy var imageLoader = ImageLoader()
  private lazy var uuidMap = [UIImageView: UUID]()
  
  private init() {}
  
  func load(_ url: URL, for imageView: UIImageView) {
    let token = imageLoader.loadImage(url as NSURL) { (result) in
      defer { self.uuidMap.removeValue(forKey: imageView) }
      
      do {
        let image = try result.get()
        
        DispatchQueue.main.async {
          imageView.image = image
        }
      } catch {
        if let removedUUID = self.uuidMap.removeValue(forKey: imageView) {
          self.imageLoader.cancelLoad(removedUUID)
        }
        print(error.localizedDescription)
      }
    }
    
    if let token = token {
      uuidMap[imageView] = token
    }
  }
  
  func cancel(for imageView: UIImageView) {
    if let uuid = uuidMap[imageView] {
      imageLoader.cancelLoad(uuid)
      uuidMap.removeValue(forKey: imageView)
    }
  }
}

extension UIImageView {
  func loadImage(at url: URL) {
    UIImageLoader.shared.load(url, for: self)
  }
  
  func cancelImageLoading() {
    UIImageLoader.shared.cancel(for: self)
  }
}
