//
//  RadioPlayerContract.swift
//  Radio
//
//  Created by Alisher on 7/11/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

protocol RadioPlayerView: BaseViewController {
  func radioAdded()
}

protocol RadioPlayerPresentation: class {
  func didTapPlayStopButton()
  func didTapAddToFavorite(with id: Int)
  func didTapRemoveFromFavorite(with id: Int)
}

protocol RadioPlayerUseCase: class {
  func addToFavorite(with id: Int)
  func removeFromFavorite(with id: Int)
}

protocol RadioPlayerInteractorOutput: InteractorOutputProtocol {
  func addedNewRadio()
  func removedRadio()
}

protocol RadioPlayerWireframe: class {
  
}
