//
//  GenreAPI.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import Alamofire

class GenreAPI {
  static func getGenries(completion: @escaping ResponseHandler) {
    let fullURL = baseURL + "/genre"
    let _ = AF.request(fullURL, method: .get, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
      switch response.result {
      case .success(let value):
        completion(value as? [[String : Any]], nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }
}
