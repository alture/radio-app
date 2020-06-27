//
//  Country.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import ObjectMapper
class Country: Mappable {
  var id: Int?
  var name: String?
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
  }
  
  static func getArray(from jsonArray: Any) -> [Country]? {
      guard let jsonArray = jsonArray as? Array<[String: Any]> else {
        return nil
      }
    
      var arr: [Country] = []
      for jsonObject in jsonArray {
        if let item = Country(JSON: jsonObject) {
              arr.append(item)
        }
      }
    
      return arr
  }
}
