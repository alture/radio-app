//
//  FilterItem.swift
//  Radio
//
//  Created by Alisher on 11/6/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

final class FilterItem: Object, Mappable, Codable {
  override func isEqual(_ object: Any?) -> Bool {
    return id == (object as? FilterItem)?.id
  }
  
  @objc dynamic var id: Int = 0
  @objc dynamic var name: String? = ""
  @objc dynamic var stations: Int = 0
  @objc dynamic var selected: Bool = false
  
  init?(map: Map) {}
  
  required init() {
    super.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    stations <- map["stations"]
    selected <- map["selected"]
  }
  
}
