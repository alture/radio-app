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
  func didTapShowFilterView(with genres: [Genre], _ countries: [Country]) {
    router?.showFilterView(with: genres, countries)
  }
  
  func getRadioList() {
    interactor?.fetchData(of: .all)
  }
  
  func getFavoriteRadioList() {
    interactor?.fetchData(of: .favorite)
  }
  
  func addToFavorite(_ id: Int) {
    interactor?.addData(id: id)
  }
  
  func removeFromFavorite(_ id: Int) {
    interactor?.removeData(id: id)
  }
  
  func addNewRadio() {
    router?.showNewRadioView()
  }
}

extension RadioListPresenter: RadioListInteractorOutput {
  
  func addedToFavorite() {
    view?.prepareResultView(with: .sucess(text: "Добавлено в изрбанное"))
  }
  
  func removedFromFavorite() {
    
  }
  
  func fetchedData(_ data: [Radio], _ type: RadioListType) {
    let availableRadios = data.filter { (radio) -> Bool in
      return radio.enabled
    }

    view?.updateViewFromModel(availableRadios)
  }
}
