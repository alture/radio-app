//
//  Radio.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import ObjectMapper

class Radio: Mappable, Equatable  {
  static func == (lhs: Radio, rhs: Radio) -> Bool {
    return lhs.id == rhs.id
  }
  
  var country: Country?
  var enabled: Bool?
  var genre: String?
  var genres: [Genre]?
  var id: Int?
  var logo: String?  
  var name: String?
  var rate: Int?
  var url: String?
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    country <- map["country"]
    enabled <- map["enabled"]
    genre <- map["genre"]
    genres <- map["genres"]
    id <- map["id"]
    logo <- map["logo"]
    name <- map["name"]
    rate <- map["rate"]
    url <- map["url"]
  }
}
