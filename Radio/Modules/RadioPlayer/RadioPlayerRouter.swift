//
//  RadioPlayerRouter.swift
//  Radio
//
//  Created by Alisher on 7/11/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class RadioPlayerRouter {
  
  // MARK: Properties
  
  weak var view: UIViewController?
  
  // MARK: Static methods
  
  static func setupModule() -> RadioPlayerViewController {
    let viewController = UIStoryboard(name: "Main",
                                    bundle: nil)
    .instantiateViewController(identifier: "RadioPlayerVC") as! RadioPlayerViewController
    let presenter = RadioPlayerPresenter()
    let router = RadioPlayerRouter()
    let interactor = RadioPlayerInteractor()
    
    viewController.presenter =  presenter
    
    presenter.view = viewController
    presenter.router = router
    presenter.interactor = interactor
    
    router.view = viewController
    
    interactor.output = presenter
    
    return viewController
  }
}

extension RadioPlayerRouter: RadioPlayerWireframe {
  // TODO: Implement wireframe methods
}
