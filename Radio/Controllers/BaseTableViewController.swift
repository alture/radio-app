//
//  BaseViewController.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import Network

protocol BaseTableViewControllerDelegate {
  func showErrorAlert(with message: String)
  func prepareResultView(with result: ViewResult)
}

class BaseTableViewController: UITableViewController, BaseTableViewControllerDelegate {
  private lazy var resultView: ResulView = {
    let view = ResulView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private var topViewController: UIViewController {
    let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    guard var topController = keyWindow?.rootViewController else {
      return self
    }
    
    while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
    }
    
    return topController
  }
  
  private lazy var resultViewTopConstraint = NSLayoutConstraint()
  private var isShowing: Bool = false
    
  func prepareResultView(with result: ViewResult) {
    DispatchQueue.main.async { [weak self] in
      self?.resultView.result = result
      self?.presentResultView()
    }
  }
  
  func showErrorAlert(with message: String) {
    let alertController = UIAlertController(title: message,
                                            message: nil,
                                            preferredStyle: .alert)
    let alertAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"),
                                    style: .default,
                                    handler: nil)
    alertController.addAction(alertAction)
    present(alertController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupResultView()
  }
  
  private func setupResultView() {
    configureResultView()
    configureResultConstraints()
  }
  
  private func configureResultView() {
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    tableView.refreshControl?.tintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
    topViewController.view.addSubview(resultView)
  }
  
  private func configureResultConstraints() {
    resultViewTopConstraint = resultView.topAnchor.constraint(
      equalTo: topViewController.view.topAnchor,
      constant: -35.0)
    
    NSLayoutConstraint.activate([
      resultViewTopConstraint,
      resultView.leadingAnchor.constraint(equalTo: topViewController.view.leadingAnchor,
                                          constant: 16.0),
      resultView.trailingAnchor.constraint(equalTo: topViewController.view.trailingAnchor,
                                           constant: -16.0),
      resultView.heightAnchor.constraint(equalToConstant: 35.0)
    ])
    
  }
  
  private func presentResultView() {
    if isShowing {
      return
    }
    
    isShowing = true
    resultViewTopConstraint.constant = topViewController.view.safeAreaInsets.top + 10
    UIView.animate(withDuration: 0.5,
                   animations: {
                    self.topViewController.view.layoutIfNeeded()
    }, completion: { _ in
      self.resultViewTopConstraint.constant = -35.0
      UIView.animate(withDuration: 0.5,
                     delay: 3.0,
                     options: [],
                     animations: {
                      self.topViewController.view.layoutIfNeeded()
      }, completion: { _ in
        self.isShowing = false
      })
    })
  }
    
}

extension BaseTableViewController: InteractorOutputProtocol {
  func handleError(_ error: Error?, _ result: ViewResult?) {
    if let result = result {
      prepareResultView(with: result)
    } else {
      if let error = error {
        showErrorAlert(with: error.localizedDescription)
      }
    }
  }
}

