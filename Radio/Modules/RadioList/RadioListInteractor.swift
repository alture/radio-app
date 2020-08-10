//
//  RadioListInteractor.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

final class RadioListInteractor {
  
  // MARK: Properties
  
  weak var output: RadioListInteractorOutput?
}

extension RadioListInteractor: RadioListUseCase {
  func fetchData(of type: RadioListType) {
    switch type {
    case .all:
      RadioAPI.getRadios { (response, error) in
        if let error = error {
          self.output?.handleError(error)
          return
        }
        if let radios = response as? [Radio] {
          self.output?.fetchedData(radios, type)
        }
      }
    case .favorite:
      RadioAPI.getFavoriteRadios { (response, error) in
        if let error = error {
          self.output?.handleError(error)
          return
        }
        
        if let radios = response as? [Radio] {
          self.output?.fetchedData(radios, type)
        }
      }
    }
  }
  
  func addData(id: Int) {
    RadioAPI.addToFavorite(id) { (error) in
      if let error = error {
        self.output?.handleError(error)
        return
      }
    }
  }
  
  func removeData(id: Int) {
    RadioAPI.removeFromFavorite(id) { (error) in
      if let error = error {
        self.output?.handleError(error)
        return
      }
    }
  }
}
