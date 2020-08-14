//
//  Radio.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

final class Radio: Mappable, Codable, Equatable {
  static func == (lhs: Radio, rhs: Radio) -> Bool {
    return lhs.id == rhs.id
  }
  
//  override static func ignoredProperties() -> [String] {
//      return ["id"]
//  }
  
//  override func isEqual(_ object: Any?) -> Bool {
//    return id == (object as? Radio)?.id
//  }
  
  var country: Country?
  var enabled: Bool = false
  var genre: String?
  var genres: [Genre]?
  var id: Int = 0
  var logo: String?
  var name: String?
  var rate: Int = 0
  var url: String?
  var otherUrl: [RadioURL] = []
  
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
    otherUrl <- map["urls"]
  }
}

final class RadioURL: Mappable, Codable {
  var url: String?
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    url <- map["url"]
  }
}
