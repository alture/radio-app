//
//  Track.swift
//  Radio
//
//  Created by Alisher on 9/7/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class Track: NSObject {
  var trackName: String
  var artistName: String
  var trackCover: String?
  
  init(trackName: String,
       artistName: String,
       trackCover: String? = nil) {
    self.trackName = trackName
    self.artistName = artistName
    self.trackCover = trackCover
  }
}
