//
//  Country.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

final class Country: Object, Mappable, Codable {
//  static func == (lhs: Country, rhs: Country) -> Bool {
//    return lhs.id == rhs.id && lhs.name == rhs.name
//  }
  
  override func isEqual(_ object: Any?) -> Bool {
    return id == (object as? Country)?.id
  }
    
  @objc dynamic var id: Int = 0
  @objc dynamic var name: String? = ""
  
  required init?(map: Map) {}
  
  required init() {
    super.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
  }
}
