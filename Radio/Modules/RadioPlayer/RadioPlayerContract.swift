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
}

protocol RadioPlayerUseCase: class {
  func addFavoriteRadio(with id: Int)
}

protocol RadioPlayerInteractorOutput: InteractorOutputProtocol {
  func addedNewRadio()
}

protocol RadioPlayerWireframe: class {
  
}
