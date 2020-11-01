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
  func didTapRemoveFromFavorite(with id: Int) {
    interactor?.removeFromFavorite(with: id)
  }
  
  func didTapAddToFavorite(with id: Int) {
    interactor?.addToFavorite(with: id)
  }
  
  func didTapPlayStopButton() {
   
  }  
  
}

extension RadioPlayerPresenter: RadioPlayerInteractorOutput {
  func removedRadio() {
    
  }
  
  func handleError(_ error: Error?, _ result: ViewResult?) {
    view?.handleError(error, result)
  }
  
  func addedNewRadio() {
    view?.radioAdded()
  }
  
  // TODO: implement interactor output methods
}
