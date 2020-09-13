//
//  RadioPlayerInteractor.swift
//  Radio
//
//  Created by Alisher on 7/11/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

final class RadioPlayerInteractor {
  
  // MARK: Properties
  
  weak var output: RadioPlayerInteractorOutput?
}

extension RadioPlayerInteractor: RadioPlayerUseCase {
  func addToFavorite(with id: Int) {
    RadioAPI.addToFavorite(id) { (error) in
      if let error = error {
        self.output?.handleError(error, nil)
      } else {
        self.output?.addedNewRadio()
      }
    }
  }
  
  func removeFromFavorite(with id: Int) {
    RadioAPI.removeFromFavorite(id) { (error) in
      if let error = error {
        self.output?.handleError(error, nil)
      } else {
        self.output?.removedRadio()
      }
    }
  }
  
  // TODO: Implement use case methods
}
