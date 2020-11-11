//
//  RadioFilterContract.swift
//  Radio
//
//  Created by Alisher on 6/30/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

protocol RadioFilterView: BaseViewController {
  func updateViewFromModel(_ filter: Filter)
  func uploaded()
}

protocol RadioFilterPresentation: class {
  func viewDidLoad()
  func appendNewFilter(_ newFilter: Filter)
}

protocol RadioFilterUseCase: class {
  func fetchData()
  func uploaData(_ data: Filter)
}

protocol RadioFilterInteractorOutput: InteractorOutputProtocol {
  func fetchedDate(_ filter: Filter)
  func uploadedData()
}

protocol RadioFilterWireframe: class {
  // TODO: Declare wireframe methods
}
