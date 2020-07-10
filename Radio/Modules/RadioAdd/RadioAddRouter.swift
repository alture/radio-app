//
//  RadioAddRouter.swift
//  Radio
//
//  Created by Alisher on 7/7/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class RadioAddRouter {
  
  // MARK: Properties
  
  weak var view: UITableViewController?
  
  // MARK: Static methods
  
  static func setupModule() -> RadioAddViewController {
    let viewController = UIStoryboard(name: "Main",
                                    bundle: nil)
    .instantiateViewController(identifier: "RadioAddVC") as! RadioAddViewController
    let presenter = RadioAddPresenter()
    let router = RadioAddRouter()
    let interactor = RadioAddInteractor()
    
    viewController.presenter =  presenter
    
    presenter.view = viewController
    presenter.router = router
    presenter.interactor = interactor
    
    router.view = viewController
    interactor.output = presenter
    
    return viewController
  }
}

extension RadioAddRouter: RadioAddWireframe {

}
