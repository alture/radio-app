//
//  RadioListPresenter.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

final class RadioListPresenter {
  
  // MARK: Properties
  
  weak var view: RadioListView?
  var router: RadioListWireframe?
  var interactor: RadioListUseCase?
}

extension RadioListPresenter: RadioListPresentation {
  func getRadioList() {
    interactor?.fetchData()
  }
}

extension RadioListPresenter: RadioListInteractorOutput {  
  func fetchedData(_ data: [Radio]) {
    view?.updateViewFromModel(data)
  }
}
