//
//  RadioAddPresenter.swift
//  Radio
//
//  Created by Alisher on 7/7/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
final class RadioAddPresenter {
  
  // MARK: Properties
  
  weak var view: RadioAddView?
  var router: RadioAddWireframe?
  var interactor: RadioAddUseCase?
}

extension RadioAddPresenter: RadioAddPresentation {
  func didTapAddRadioButton(with image: UIImage?, _ name: String, _ url: String) {
    interactor?.addNewRadio(with: image, name, url)
  }
}

extension RadioAddPresenter: RadioAddInteractorOutput {
  func handleError(_ error: Error?, _ result: ViewResult?) {
    view?.handleError(error, result)
  }
  
  func addedNewRadio() {
    view?.dismiss()
  }
}
