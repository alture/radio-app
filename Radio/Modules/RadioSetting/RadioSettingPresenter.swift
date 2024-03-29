//
//  RadioSettingPresenter.swift
//  Radio
//
//  Created by Alisher on 8/6/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

final class RadioSettingPresenter {
  
  // MARK: Properties
  
  weak var view: RadioSettingView?
  var router: RadioSettingWireframe?
  var interactor: RadioSettingUseCase?
}

extension RadioSettingPresenter: RadioSettingPresentation {
  // TODO: implement presentation methods
}

extension RadioSettingPresenter: RadioSettingInteractorOutput {
  func handleError(_ error: Error?, _ result: ViewResult?) {
    view?.handleError(error, result)
  }
  // TODO: implement interactor output methods
}
