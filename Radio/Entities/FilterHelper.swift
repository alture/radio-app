//
//  FilterHelper.swift
//  Radio
//
//  Created by Alisher on 8/2/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation

import Foundation
import RealmSwift

enum Filter {
  case filtered
  case all
}

final class FilterHelper {
  static let shared = FilterHelper()
  
  private lazy var realm: Realm = {
    let rlm: Realm
    do {
      rlm = try Realm()
//      rlm.deleteAll()
    } catch let error {
      fatalError(error.localizedDescription)
    }
    return rlm
  }()
  
  private init() {}
  
//  func save(genres: [Genre], countries: [Country]) throws {
//    let oldFilterRealmModel = realm.objects(FilterRealmModel.self)
//    let filterRealmModel = FilterRealmModel()
//    filterRealmModel.genres.append(objectsIn: genres)
//    filterRealmModel.countries.append(objectsIn: countries)
//    do {
//      try realm.write {
//        realm.delete(oldFilterRealmModel)
//        realm.add(filterRealmModel)
//      }
//    } catch let error {
//      throw error
//    }
//  }
  
//  func get() throws -> ([Genre], [Country]) {
//    
//  }

}
//
//final class FilterRealmModel: Object {
//  let genres = List<Genre>()
//  let countries = List<Country>()
//}
//
