//
//  CountryAPI.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import Alamofire

class CountryAPI {
  static func getCountries(completion: @escaping ResponseHandler) {
    let fullURL = baseAPI + "/country"
    Alamofire.request(fullURL, method: .get, encoding: URLEncoding.default, headers: headers).responseArray() { (response: DataResponse<[Country]>) in
      switch response.result {
      case .success(let value):
        completion(value, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }
}
