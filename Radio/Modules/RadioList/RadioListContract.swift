//
//  RadioListContract.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

protocol RadioListView: BaseTableViewController {
  func updateViewFromModel(_ model: [Radio])
  func updateViewFromFetchedList(_ radioList: [Radio])
}

protocol RadioListPresentation: class {
  func getRadioList(from startIndex: Int, to endIndex: Int)
  func getFavoriteRadioList(from startIndex: Int, to endIndex: Int)
  func didTapSearchRadio(from text: String)
  func addToFavorite(_ id: Int)
  func removeFromFavorite(_ id: Int)
  func didTapShowFilterView()
  func addNewRadio()
}

protocol RadioListUseCase: class {
  func fetchData(of type: RadioListType, from index: Int, to endIndex: Int)
  func searchRadio(from text: String)
  func addData(id: Int)
  func removeData(id: Int)
}

protocol RadioListInteractorOutput: InteractorOutputProtocol {
  func fetchedData(_ data: [Radio])
  func fetchedSearchData(_ data: [Radio])
  func addedToFavorite()
  func removedFromFavorite()
}

protocol RadioListWireframe: class {
  func showFilterView()
  func showNewRadioView()
}
