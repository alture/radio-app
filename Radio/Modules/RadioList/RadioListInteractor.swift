//
//  RadioListInteractor.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
final class RadioListInteractor {
  
  // MARK: Properties
  
  weak var output: RadioListInteractorOutput?
}

extension RadioListInteractor: RadioListUseCase {
  func fetchData(of type: RadioListType, from startIndex: Int, to endIndex: Int) {
    switch type {
    case .all:
      RadioAPI.getRadios(from: startIndex, to: endIndex) { (response, error) in
        if let error = error {
          self.output?.handleError(error, .failure(text: error.localizedDescription))
          return
        }
        if let radios = response as? [Radio] {
          self.output?.fetchedData(radios, type)
        }
      }
    case .favorite:
      RadioAPI.getFavoriteRadios(from: startIndex) { (response, error) in
        if let error = error {
          self.output?.handleError(error, .failure(text: error.localizedDescription))
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
        self.output?.handleError(error, nil)
        return
      }
    }
  }
  
  func removeData(id: Int) {
    RadioAPI.removeFromFavorite(id) { (error) in
      if let error = error {
        self.output?.handleError(error, nil)
        return
      }
    }
  }
}
