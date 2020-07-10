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
  
  weak var view: BaseViewController?
  
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
    let navVC = UINavigationController(rootViewController: vc)
    vc.delegate = view as? RadioFilterViewControllerDelegate
    view?.present(navVC, animated: true, completion: nil)
  }
  
  func showNewRadioView() {
    let vc = RadioAddRouter.setupModule()
    vc.title = "Добавить станцию"
    vc.delegate = view as? RadioAddViewControllerDelegate
    let navVC = UINavigationController(rootViewController: vc)
    view?.present(navVC, animated: true)
  }
}
