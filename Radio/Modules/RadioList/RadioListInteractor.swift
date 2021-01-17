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
      RadioAPI.getRadios(from: startIndex, to: endIndex) { [weak self] (response, error) in
        guard let `self` = self else { return }
        
        if let error = error {
          self.output?.handleError(error, .failure(text: error.localizedDescription))
          return
        }
        if let radios = response as? [Radio] {
          self.output?.fetchedData(radios)
        }
      }
    case .favorite:
      RadioAPI.getFavoriteRadios(from: startIndex) { [weak self] (response, error) in
        guard let `self` = self else { return }
        
        if let error = error {
          self.output?.handleError(error, .failure(text: error.localizedDescription))
          return
        }
        
        if let radios = response as? [Radio] {
          self.output?.fetchedData(radios)
        }
      }
    }
  }
  
  func addData(id: Int) {
    RadioAPI.addToFavorite(id) { [weak self] (error) in
      guard let `self` = self else { return }
      
      if let error = error {
        self.output?.handleError(error, .warning(text: error.localizedDescription))
        return
      }
    }
  }
  
  func removeData(id: Int) {
    RadioAPI.removeFromFavorite(id) { [weak self] (error) in
      guard let `self` = self else { return }
      
      if let error = error {
        self.output?.handleError(error, .warning(text: error.localizedDescription))
        return
      }
    }
  }
  
  func searchRadio(from text: String) {
    RadioAPI.searchRadio(from: text) { [weak self] (result) in
      guard let `self` = self else { return }
      
      switch result {
      case .failure(let error):
        self.output?.handleError(error, .warning(text: error.localizedDescription))
      case .success(let radioList):
        self.output?.fetchedSearchData(radioList)
      }
    }
  }
}
