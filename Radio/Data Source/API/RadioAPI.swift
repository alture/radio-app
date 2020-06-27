//
//  RadioAPI.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import Alamofire

class RadioAPI {
  static func getRadios(completion: @escaping ResponseHandler) {
    let fullURL = baseURL + "/radio"
    AF.request(fullURL, method: .get, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        completion(value as? [[String : Any]], nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }
  
  static func createRadio(with name: String, url: String, logoURL: String, completion: @escaping (Error?) -> Void) {
    let fullURL = baseURL + "/radio"
    let parameters = [
      "name": name,
      "url": url,
      "logo": url
    ]
    
    AF.request(fullURL, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: headers).responseJSON { (response) in
      switch response.result {
      case .success:
        completion(nil)
      case .failure(let error):
        completion(error)
      }
    }
  }
  
  static func getFavoriteRadios(completion: @escaping ResponseHandler) {
    let fullURL = baseURL + "/radio/my"
    AF.request(fullURL, method: .get, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        completion(value as? [[String : Any]], nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }
  
  static func addToFavorite(_ id: Int, completion: @escaping (Error?) -> Void) {
    let fullURL = baseURL + "/radio/\(id)/like"
    AF.request(fullURL, method: .post, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//      print(response.response?.statusCode)
      switch response.result {
      case .success:
        completion(nil)
      case .failure(let error):
        completion(error)
      }
    }
  }
  
  static func removeFromFavorite(_ id: Int, completion: @escaping (Error?) -> Void) {
    let fullURL = baseURL + "/radio/\(id)/dislike"
    AF.request(fullURL, method: .post, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//      print(response.response?.statusCode)
      switch response.result {
      case .success:
        completion(nil)
      case .failure(let error):
        completion(error)
      }
    }
  }
}

