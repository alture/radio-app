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
}

protocol RadioListPresentation: class {
  func getRadioList(from index: Int)
  func getFavoriteRadioList(from index: Int)
  func addToFavorite(_ id: Int)
  func removeFromFavorite(_ id: Int)
  func didTapShowFilterView()
  func addNewRadio()
}

protocol RadioListUseCase: class {
  func fetchData(of type: RadioListType, from index: Int)
  func addData(id: Int)
  func removeData(id: Int)
}

protocol RadioListInteractorOutput: InteractorOutputProtocol {
  func fetchedData(_ data: [Radio], _ type: RadioListType)
  func addedToFavorite()
  func removedFromFavorite()
}

protocol RadioListWireframe: class {
  func showFilterView()
  func showNewRadioView()
}
