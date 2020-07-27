//
//  Connectivity.swift
//  Radio
//
//  Created by Alisher on 7/14/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Alamofire
import Foundation

struct Connectivity {
  static let sharedInstance = NetworkReachabilityManager()!
  static var isConnectedToInternet:Bool {
      return self.sharedInstance.isReachable
  }
}
