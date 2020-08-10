//
//  RadioSettingRouter.swift
//  Radio
//
//  Created by Alisher on 8/6/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class RadioSettingRouter {
  
  // MARK: Properties
  
  weak var view: UIViewController?
  
  // MARK: Static methods
  
  static func setupModule() -> RadioSettingTableViewController {
    let viewController = RadioSettingTableViewController()
    let presenter = RadioSettingPresenter()
    let router = RadioSettingRouter()
    let interactor = RadioSettingInteractor()
    
    viewController.presenter =  presenter
    
    presenter.view = viewController
    presenter.router = router
    presenter.interactor = interactor
    
    router.view = viewController
    
    interactor.output = presenter
    
    return viewController
  }
}

extension RadioSettingRouter: RadioSettingWireframe {
  // TODO: Implement wireframe methods
}
