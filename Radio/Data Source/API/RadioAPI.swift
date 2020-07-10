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
  
  static func createRadio(with name: String, url: String, logoURL: String, completion: @escaping (Error?) -> Void) {
    let fullURL = baseAPI + "/radio"
    let parameters = [
      "name": name,
      "url": url,
      "logo": url
    ]
    
    Alamofire.request(fullURL, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
      switch response.result {
      case .success:
        completion(nil)
      case .failure(let error):
        completion(error)
      }
    }
  }
  
  static func getFavoriteRadios(completion: @escaping ResponseHandler) {
    let fullURL = baseAPI + "/radio/my"
    Alamofire.request(fullURL, method: .get, encoding: URLEncoding.default, headers: headers).responseArray(keyPath: "Result") { (response: DataResponse<[Radio]>) in
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
      case .success:
        completion(nil)
      case .failure(let error):
        print(error)
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

