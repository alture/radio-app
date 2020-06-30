//
//  RadioFilterRouter.swift
//  Radio
//
//  Created by Alisher on 6/30/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class RadioFilterRouter {
  
  // MARK: Properties
  
  weak var view: UIViewController?
  
  // MARK: Static methods
  
  static func setupModule() -> RadioFilterViewController {
    let viewController = RadioFilterViewController()
    let presenter = RadioFilterPresenter()
    let router = RadioFilterRouter()
    let interactor = RadioFilterInteractor()
    
    viewController.presenter =  presenter
    
    presenter.view = viewController
    presenter.router = router
    presenter.interactor = interactor
    
    router.view = viewController
    
    interactor.output = presenter
    
    return viewController
  }
}

extension RadioFilterRouter: RadioFilterWireframe {
  // TODO: Implement wireframe methods
}
