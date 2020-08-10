//
//  RadioPlayerContract.swift
//  Radio
//
//  Created by Alisher on 7/11/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

protocol RadioPlayerView: class {
  func updateView()
}

protocol RadioPlayerPresentation: class {
  func didTapPlayStopButton()
}

protocol RadioPlayerUseCase: class {
  // TODO: Declare use case methods
}

protocol RadioPlayerInteractorOutput: InteractorOutputProtocol {
  // TODO: Declare interactor output methods
}

protocol RadioPlayerWireframe: class {
  // TODO: Declare wireframe methods
}
