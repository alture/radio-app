//
//  RadioFilterContract.swift
//  Radio
//
//  Created by Alisher on 6/30/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

protocol RadioFilterView: class {
  func updateViewFromModel(_ genre: [Genre], _ country: [Country])
}

protocol RadioFilterPresentation: class {
  func viewDidLoad()
}

protocol RadioFilterUseCase: class {
  func fetchData()
}

protocol RadioFilterInteractorOutput: InteractorOutputProtocol {
  func fetchedDate(_ genre: [Genre], _ country: [Country])
}

protocol RadioFilterWireframe: class {
  // TODO: Declare wireframe methods
}
