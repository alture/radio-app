//
//  RadioFilterInteractor.swift
//  Radio
//
//  Created by Alisher on 6/30/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

final class RadioFilterInteractor {
  
  // MARK: Properties
  
  weak var output: RadioFilterInteractorOutput?
}

extension RadioFilterInteractor: RadioFilterUseCase {
  func fetchData() {
    FilterAPI.getFilter { (response, error) in
      if let error = error {
        self.output?.handleError(error, .failure(text: error.localizedDescription))
        return
      }
      
      if let filter = response as? Filter {
        self.output?.fetchedDate(filter)
      }
    }
  }
  
  func uploaData(_ data: Filter) {
    FilterAPI.uploadFilter(data) { (error) in
      if let error = error {
        self.output?.handleError(error, .warning(text: error.localizedDescription))
      } else {
        self.output?.uploadedData()
      }
    }
  }
}
