//
//  Country.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import ObjectMapper
class Country: Mappable, Equatable {
  static func == (lhs: Country, rhs: Country) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name
  }
  
  var id: Int?
  var name: String?
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
  }
}
