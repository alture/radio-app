//
//  Constant.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation
import Alamofire


let baseAPI = "https://panel.radio.rvision.tv/api/v1"
let headers: HTTPHeaders = [
  "X-RADIO-CLIENT-ID": "\(UIDevice.current.identifierForVendor?.uuidString ?? "")-\(Locale.current)",
  "Content-Type":"application/json",
]

typealias ResponseHandler = ([Any]?, Error?) -> Void
