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
  
  static func getRadios(from startIndex: Int, to endIndex: Int, completion: @escaping ResponseHandler) {
    let fullURL = baseAPI + "/radio"
    let parameters = [
      "index": startIndex,
      "limit": endIndex
    ]
    
    Alamofire.request(fullURL, method: .get, parameters: parameters, encoding: URLEncoding.queryString, headers: headers).validate().responseArray() { (response: DataResponse<[Radio]>) in
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
  
  static func getFavoriteRadios(from index: Int, completion: @escaping ResponseHandler) {
    let fullURL = baseAPI + "/radio/my"
    Alamofire.request(fullURL, method: .get, encoding: URLEncoding.queryString, headers: headers).responseArray() { (response: DataResponse<[Radio]>) in
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
      case .success(_):
        completion(nil)
      case .failure(let error):
        completion(error)
      }
    }
  }
  
  static func removeFromFavorite(_ id: Int, completion: @escaping (Error?) -> Void) {
    let fullURL = baseAPI + "/radio/\(id)/dislike"
    Alamofire.request(fullURL, method: .post, encoding: URLEncoding.default, headers: headers).responseData { (response) in
      switch response.result {
      case .success:
        completion(nil)
      case .failure(let error):
        completion(error)
      }
    }
  }
  
  static func searchRadio(from text: String, completion: @escaping (Swift.Result<[Radio], Error>) -> Void) {
    let fullURL = baseAPI + "/radio/search"
    
    let parameters = [
      "q": text,
    ]
        
    Alamofire.request(fullURL,
                      method: .get,
                      parameters: parameters,
                      encoding: URLEncoding.queryString,
                      headers: headers).validate().responseArray { (response: DataResponse<[Radio]>) in
                        switch response.result {
                        case .failure(let error):
                          completion(.failure(error))
                        case .success(let value):
                          print(value.count)
                          completion(.success(value))
                        }
                      }
  }
}

