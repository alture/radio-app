//
//  FilterAPI.swift
//  Radio
//
//  Created by Alisher on 11/6/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import Alamofire

final class FilterAPI {
  static func getFilter(completion: @escaping (Any?, Error?) -> Void) {
    let fullURL = baseAPI + "/filter"

    Alamofire.request(fullURL, method: .get, encoding: URLEncoding.default, headers: headers).responseObject { (response: DataResponse<Filter>) in
          switch response.result {
          case .success(let value):
            completion(value, nil)
          case .failure(let error):
            completion(nil, error)
          }
    }
  }
  
  static func uploadFilter(_ filter: Filter, completion: @escaping (Error?) -> Void) {
    let fullURL = baseAPI + "/filter"
    do {
      let jsonData = try JSONEncoder().encode(filter)
      var request = try URLRequest(url: fullURL, method: .post, headers: headers)
      request.httpBody = jsonData

      Alamofire.request(request).responseData { (response) in
        switch response.result {
        case .success(_):
          completion(nil)
        case .failure(let error):
          completion(error)
        }
      }
    } catch {
      completion(error)
    }
  }
}
