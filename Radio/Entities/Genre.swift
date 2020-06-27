//
//  Genre.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import ObjectMapper

class Genre: Mappable {
  var id: Int?
  var name: String?
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
  }
  
  static func getArray(from jsonArray: Any) -> [Genre]? {
      guard let jsonArray = jsonArray as? Array<[String: Any]> else {
        return nil
      }
    
      var arr: [Genre] = []
      for jsonObject in jsonArray {
        if let item = Genre(JSON: jsonObject) {
              arr.append(item)
        }
      }
    
      return arr
  }
}
