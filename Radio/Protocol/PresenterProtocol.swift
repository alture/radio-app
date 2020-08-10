//
//  PresenterProtocol.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import Foundation

protocol InteractorOutputProtocol: class {
  func handleError(_ error: Error?, _ result: Result?)
}

extension InteractorOutputProtocol {
  func handleError(_ error: Error?, _ result: Result? = nil) { }
}

