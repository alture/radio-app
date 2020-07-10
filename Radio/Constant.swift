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
  "X-RADIO-CLIENT-ID": "adcb64ee-b6e5-11ea-b3de-0242ac130004-\(Locale.current)" ,
]

typealias ResponseHandler = ([Any]?, Error?) -> Void
