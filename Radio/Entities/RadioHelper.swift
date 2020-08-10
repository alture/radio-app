////
////  RadioHelper.swift
////  Radio
////
////  Created by Alisher on 8/5/20.
////  Copyright © 2020 Alisher. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//
//final class RadioHelper {
//  static let shared = RadioHelper()
//  
//  private lazy var realm: Realm = {
//    let rlm: Realm
//    do {
//      rlm = try Realm()
//    } catch let error {
//      fatalError(error.localizedDescription)
//    }
//    return rlm
//  }()
//  
//  private init() {}
//  
//  func save(_ radioList: [Radio], _ type: RadioListType) throws {
//    let radioListRealmModel = realm.objects(RadioListRealmModel.self)
//    switch type {
//    case .favorite:
//      let newRadioListRealmModel = RadioListRealmModel()
//      newRadioListRealmModel.favoriteRadioList.append(objectsIn: radioList)
//      
//      if let first = radioListRealmModel.first {
//        newRadioListRealmModel.radioList = first.radioList
//      }
//      
//      do {
//        try realm.write {
//          realm.delete(radioListRealmModel)
//          realm.add(newRadioListRealmModel)
//        }
//      } catch let error {
//        throw error
//      }
//    case .all:
//      break
////      if let first = radioListRealmModel.first {
////        first.radioList.removeAll()
////        first.radioList.append(objectsIn: radioList)
////      } else {
////        let newRadioListRealmModel = RadioListRealmModel()
////        newRadioListRealmModel.radioList.append(objectsIn: radioList)
////        realm.beginWrite()
////        realm.add(newRadioListRealmModel)
////        do {
////          try <#throwing expression#>
////        } catch <#pattern#> {
////          <#statements#>
////        }
////      }
//    }
//  }
//  
//  func get(_ type: RadioListType) throws -> [Radio]? {
//    let radioListRealmModel = realm.objects(RadioListRealmModel.self)
//    guard let first = radioListRealmModel.first else {
//      return nil
//    }
//    switch type {
//    case .favorite:
//      print(Array(first.favoriteRadioList).count)
//      return Array(first.favoriteRadioList)
//    case .all:
//      return Array(first.radioList)
//    }
//  }
//  
//}
//
//final class RadioListRealmModel: Object {
//  var radioList = List<Radio>()
//  var favoriteRadioList = List<Radio>()
//}
//
