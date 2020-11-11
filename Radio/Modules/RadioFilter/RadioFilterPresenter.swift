//
//  RadioFilterPresenter.swift
//  Radio
//
//  Created by Alisher on 6/30/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

final class RadioFilterPresenter {
  
  // MARK: Properties
  
  weak var view: RadioFilterView?
  var router: RadioFilterWireframe?
  var interactor: RadioFilterUseCase?
}

extension RadioFilterPresenter: RadioFilterPresentation {
  func viewDidLoad() {
    interactor?.fetchData()
  }
  
  func appendNewFilter(_ newFilter: Filter) {
    interactor?.uploaData(newFilter)
  }
}

extension RadioFilterPresenter: RadioFilterInteractorOutput {
  func fetchedDate(_ filter: Filter) {
    view?.updateViewFromModel(filter)
  }
  
  func handleError(_ error: Error?, _ result: ViewResult?) {
    view?.handleError(error, result)
  }
  
  func uploadedData() {
    view?.uploaded()
  }
}
