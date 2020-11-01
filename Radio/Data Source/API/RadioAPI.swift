//
//  RadioAPI.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class RadioAPI {
  
  static func getRadios(completion: @escaping ResponseHandler) {
    let fullURL = baseAPI + "/radio"
    
    print("Code: \(Locale.current.languageCode), Region: \(Locale.current)")
    
    Alamofire.request(fullURL, method: .get, encoding: URLEncoding.default, headers: headers).validate().responseArray() { (response: DataResponse<[Radio]>) in
      switch response.result {
      case .success(let value):
        completion(value, nil)
      case .failure(let error):
        print(error.localizedDescription)
        completion(nil, error)
      }
    }
    
  }
  
  static func createRadio(with name: String, url: String, image: UIImage?, completion: @escaping (Error?) -> Void) {
    let fullURL = baseAPI + "/radio"
    let parameters = [
      "name": name,
      "url": url
    ]
    
    Alamofire.upload(multipartFormData: { (formData) in
      for (key, value) in parameters {
        formData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
      }

      if let data = image?.jpegData(compressionQuality: 0.7) {
        formData.append(data,
                        withName: "logo",
                        fileName: "logo.png",
                        mimeType: "image/png")
      }
    }, usingThreshold: UInt64.init(),
       to: fullURL,
       method: .post,
      headers: headers) { (result) in
      switch result {
      case .success(_, _, _):
        completion(nil)
      case .failure(let error):
        completion(error)
      }
    }
  }
  
  static func getFavoriteRadios(completion: @escaping ResponseHandler) {
    let fullURL = baseAPI + "/radio/my"
    Alamofire.request(fullURL, method: .get, encoding: URLEncoding.default, headers: headers).responseArray() { (response: DataResponse<[Radio]>) in
      switch response.result {
      case .success(let value):
        completion(value, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }
  
  static func addToFavorite(_ id: Int, completion: @escaping (Error?) -> Void) {
    let fullURL = baseAPI + "/radio/\(id)/like"
    Alamofire.request(fullURL, method: .post, encoding: URLEncoding.default , headers: headers).responseData { (response) in
      switch response.result {
      case .success(let result):
        print(result)
        completion(nil)
      case .failure(let error):
        completion(error)
      }
    }
  }
  
  static func removeFromFavorite(_ id: Int, completion: @escaping (Error?) -> Void) {
    let fullURL = baseAPI + "/radio/\(id)/dislike"
    Alamofire.request(fullURL, method: .post, encoding: URLEncoding.default , headers: headers).responseData { (response) in
      switch response.result {
      case .success:
        completion(nil)
      case .failure(let error):
        completion(error)
      }
    }
  }
}

