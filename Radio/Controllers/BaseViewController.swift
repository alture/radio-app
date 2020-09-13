//
//  BaseViewController.swift
//  Radio
//
//  Created by Alisher on 6/26/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import Network

protocol BaseViewControllerDelegate {
  func showErrorAlert(with message: String)
  func prepareResultView(with result: Result, _ style: Style?)
}

enum Style {
  case show
  case hide
  case showAndHide
}

class BaseViewController: UIViewController, BaseViewControllerDelegate {
  private lazy var resultView: ResulView = {
    let view = ResulView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    view.alpha = 0.0
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
  
  private lazy var resultViewBottomConstraint = NSLayoutConstraint()
    
  func prepareResultView(with result: Result, _ style: Style? = .showAndHide) {
    resultView.result = result
    topViewController.view.endEditing(true)
    
    switch style {
    case .showAndHide:
      showResultView()
      hideResultView()
    case .show: showResultView()
    case .hide: hideResultView()
    case .none:
      break
    }
  }
  
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
    setupNotificationCenter()
    setupResultView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
//    setupMonitor()
  }
  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    setupNotificationCenter()
//  }
//
//  override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//    removeNotificationCenter()
//  }
  
  private func setupNotificationCenter() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow(_:)),
                                           name: UIResponder.keyboardWillShowNotification ,
                                           object:nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide(_:)),
                                           name: UIResponder.keyboardWillHideNotification ,
                                           object:nil)
  }
  
  private func removeNotificationCenter() {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  private func setupResultView() {
    configureResultView()
    configureResultConstraints()
  }
  
  private func configureResultView() {
    topViewController.view.addSubview(resultView)
  }
  
  private func configureResultConstraints() {
    resultViewBottomConstraint = resultView.bottomAnchor.constraint(
      equalTo: topViewController.view.safeAreaLayoutGuide.bottomAnchor,
      constant: -134.0)
    
    NSLayoutConstraint.activate([
      resultViewBottomConstraint,
      resultView.leadingAnchor.constraint(equalTo: topViewController.view.leadingAnchor,
                                          constant: 8.0),
      resultView.trailingAnchor.constraint(equalTo: topViewController.view.trailingAnchor,
                                           constant: -8.0),
      resultView.heightAnchor.constraint(equalToConstant: 35.0)
    ])
    
  }
  
  private func showResultView() {
    UIView.animate(withDuration: 0.4,
                   animations: {
                    self.resultView.alpha = 1.0
                    self.resultView.isHidden = false
    }) { (_) in
      self.resultView.alpha = 1.0
    }
  }
  
  private func hideResultView() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
      UIView.animate(withDuration: 0.4,
                     animations: {
                      self.resultView.alpha = 0.0
      }) { (_) in
        self.resultView.alpha = 0.0
        self.resultView.isHidden = true
      }
    }
  }
  
  
  @objc private func keyboardWillShow(_ notification: Notification) {
//    let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
    
    
  }

  @objc private func keyboardWillHide(_ notification: Notification) {
    
  }
    
}

extension BaseViewController: InteractorOutputProtocol {
  func handleError(_ error: Error?, _ result: Result?) {
    if let result = result {
      prepareResultView(with: result)
    } else {
      if let error = error {
        showErrorAlert(with: error.localizedDescription)
      }
    }
  }
}
