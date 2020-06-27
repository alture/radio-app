//
//  BaseViewController.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

protocol BaseViewControllerDelegate {
  func showErrorAlert(with message: String)
}

class BaseViewController: UIViewController, BaseViewControllerDelegate {
  func showErrorAlert(with message: String) {
    let alertController = UIAlertController(title: message,
                                            message: nil,
                                            preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "Ок",
                                    style: .default,
                                    handler: nil)
    alertController.addAction(alertAction)
    present(alertController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension BaseViewController: InteractorOutputProtocol {
  func handleError(_ error: Error) {
    showErrorAlert(with: error.localizedDescription)
  }
}
