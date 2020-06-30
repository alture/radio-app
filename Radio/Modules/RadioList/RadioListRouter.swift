//
//  RadioListRouter.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class RadioListRouter {
  
  // MARK: Properties
  
  weak var view: UIViewController?
  
  // MARK: Static methods
  
  static func setupModule() -> RadioListViewController {
    let viewController = UIStoryboard(name: "Main",
                                      bundle: nil)
      .instantiateViewController(identifier: "RadioListVC") as! RadioListViewController
    let presenter = RadioListPresenter()
    let router = RadioListRouter()
    let interactor = RadioListInteractor()
    
    viewController.presenter =  presenter
    
    presenter.view = viewController
    presenter.router = router
    presenter.interactor = interactor
    
    router.view = viewController
    
    interactor.output = presenter
    
    return viewController
  }
}

extension RadioListRouter: RadioListWireframe {
  func showFilterView() {
    let vc = RadioFilterRouter.setupModule()
    view?.present(vc, animated: true, completion: nil)
  }
}
