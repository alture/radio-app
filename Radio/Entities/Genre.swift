//
//  Genre.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

final class Genre: Object, Mappable, Codable {  
  override func isEqual(_ object: Any?) -> Bool {
    return id == (object as? Genre)?.id
  }
  
  @objc dynamic var id: Int = 0
  @objc dynamic var name: String? = ""
  @objc dynamic var stations: Int = 0
  
  required init?(map: Map) {}
  
  required init() {
    super.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    stations <- map["stations"]
  }
}
