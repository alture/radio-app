//
//  RadioAddInteractor.swift
//  Radio
//
//  Created by Alisher on 7/7/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
final class RadioAddInteractor {
  
  // MARK: Properties
  
  weak var output: RadioAddInteractorOutput?
}

extension RadioAddInteractor: RadioAddUseCase {
  func addNewRadio(with image: UIImage?, _ name: String, _ url: String) {
    RadioAPI.createRadio(with: name, url: url, image: image) { (error) in
      if let error = error {
        self.output?.handleError(error, .failure(text: NSLocalizedString("Станция с таким потоком существует", comment: "Добавление новой станций")))
      } else {
        self.output?.addedNewRadio()
      }
    }
  }
}
