//
//  RadioListContract.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

protocol RadioListView: class {
  func updateViewFromModel(_ model: [Radio]) 
}

protocol RadioListPresentation: class {
  func getRadioList()
}

protocol RadioListUseCase: class {
  func fetchData()
}

protocol RadioListInteractorOutput: InteractorOutputProtocol {
  func fetchedData(_ data: [Radio])
}

protocol RadioListWireframe: class {
  // TODO: Declare wireframe methods
}
