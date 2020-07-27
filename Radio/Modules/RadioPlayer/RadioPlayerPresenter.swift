//
//  RadioPlayerPresenter.swift
//  Radio
//
//  Created by Alisher on 7/11/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

final class RadioPlayerPresenter {
  
  // MARK: Properties
  
  weak var view: RadioPlayerView?
  var router: RadioPlayerWireframe?
  var interactor: RadioPlayerUseCase?
}

extension RadioPlayerPresenter: RadioPlayerPresentation {
  // TODO: implement presentation methods
}

extension RadioPlayerPresenter: RadioPlayerInteractorOutput {
  // TODO: implement interactor output methods
}
