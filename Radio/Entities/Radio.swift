//
//  Radio.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import ObjectMapper

class Radio: Mappable {
  var country: String?
  var countryID: Int?
  var enabled: Bool?
  var genre: String?
  var genreID: Int?
  var id: Int?
  var logo: String?
  var name: String?
  var rate: Int?
  var url: String?
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    country <- map["country"]
    countryID <- map["countryID"]
    enabled <- map["enabled"]
    genre <- map["genre"]
    genreID <- map["genreID"]
    id <- map["id"]
    logo <- map["logo"]
    name <- map["name"]
    rate <- map["rate"]
    url <- map["url"]
  }
  
  static func getArray(from jsonArray: Any) -> [Radio]? {
      guard let jsonArray = jsonArray as? Array<[String: Any]> else {
        return nil
      }
    
      var arr: [Radio] = []
      for jsonObject in jsonArray {
        if let item = Radio(JSON: jsonObject) {
              arr.append(item)
        }
      }
    
      return arr
  }
}
