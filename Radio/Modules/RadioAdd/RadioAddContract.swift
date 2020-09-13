//
//  RadioAddContract.swift
//  Radio
//
//  Created by Alisher on 7/7/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
protocol RadioAddView: BaseTableViewController {
  func dismiss()
}

protocol RadioAddPresentation: class {
  func didTapAddRadioButton(with image: UIImage?, _ name: String, _ url: String)
}

protocol RadioAddUseCase: class {
  func addNewRadio(with image: UIImage?, _ name: String, _ url: String)
}

protocol RadioAddInteractorOutput: InteractorOutputProtocol {
  func addedNewRadio()
}

protocol RadioAddWireframe: class {
  
}
