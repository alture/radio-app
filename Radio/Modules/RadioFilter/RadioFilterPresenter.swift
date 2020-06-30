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
  
}

extension RadioFilterPresenter: RadioFilterInteractorOutput {
  func fetchedDate(_ genre: [Genre], _ country: [Country]) {
    view?.updateViewFromModel(genre, country)
  }
}
