//
//  FilterHelper.swift
//  Radio
//
//  Created by Alisher on 11/6/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import ObjectMapper

final class Filter: NSObject, Mappable, Codable {
  
  var genre = [FilterItem]()
  var country = [FilterItem]()
  
  override init() {}
  required init?(map: Map) {}
  
  func mapping(map: Map) {
    genre <- map["genres"]
    country <- map["countries"]
  }
  
  func deselectItems(at section: Int) {
    if section == 0 {
      genre.forEach { $0.selected = false }
    } else {
      country.forEach { $0.selected = false }
    }
  }
  
  subscript (_ section: Int, _ row: Int) -> FilterItem {
    section == 0 ? genre[row] : country[row]
  }
  
  subscript (_ section: Int) -> [FilterItem] {
    get {
      section == 0 ? genre : country
    }
    set {
      if section == 0 {
        genre += newValue
      } else {
        country += newValue
      }
    }
  }
}
