//
//  RadioListPresenter.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
final class RadioListPresenter {
  
  // MARK: Properties
  
  weak var view: RadioListView?
  var router: RadioListWireframe?
  var interactor: RadioListUseCase?
}

extension RadioListPresenter: RadioListPresentation {
  func didTapShowFilterView() {
    router?.showFilterView()
  }
  
  func getRadioList(from startIndex: Int, to endIndex: Int) {
    interactor?.fetchData(of: .all, from: startIndex, to: endIndex)
  }
  
  func getFavoriteRadioList(from startIndex: Int, to endIndex: Int) {
    interactor?.fetchData(of: .favorite, from: startIndex, to: endIndex)
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
  
  func didTapSearchRadio(from text: String) {
    interactor?.searchRadio(from: text)
  }
}

extension RadioListPresenter: RadioListInteractorOutput {
  func handleError(_ error: Error?, _ result: ViewResult?) {
    view?.handleError(error, result)
    view?.tableView.refreshControl?.endRefreshing()
  }
  
  
  func addedToFavorite() {
    view?.prepareResultView(with: .sucess(text: NSLocalizedString("Добавлено в изрбанное", comment: "Добавлено в изрбанное")))
  }
  
  func removedFromFavorite() {
    
  }
  
  func fetchedData(_ data: [Radio]) {    
    let availableRadios = data.filter { (radio) -> Bool in
      return radio.enabled
    }

    view?.updateViewFromModel(availableRadios)
  }
  
  func fetchedSearchData(_ data: [Radio]) {
    view?.updateViewFromFetchedList(data)
  }
  
}
