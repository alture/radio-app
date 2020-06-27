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
  func fetchData() {
    RadioAPI.getRadios { (response, error) in
      if let error = error {
        self.output?.handleError(error)
        return
      }
      
      if let radios = Radio.getArray(from: response ?? []) {
        self.output?.fetchedData(radios)
      }
    }
  }
}
