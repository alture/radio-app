//
//  RadioListContract.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

protocol RadioListView: BaseViewController {
  func updateViewFromModel(_ model: [Radio]) 
}

protocol RadioListPresentation: class {
  func getRadioList()
  func getFavoriteRadioList()
  func addToFavorite(_ id: Int)
  func removeFromFavorite(_ id: Int)
  func didTapShowFilterView()
  func addNewRadio()
}

protocol RadioListUseCase: class {
  func fetchData(of type: RadioListType)
  func addData(id: Int)
  func removeData(id: Int)
}

protocol RadioListInteractorOutput: InteractorOutputProtocol {
  func fetchedData(_ data: [Radio])
  func addedToFavorite()
  func removedFromFavorite()
}

protocol RadioListWireframe: class {
  func showFilterView()
  func showNewRadioView()
}
