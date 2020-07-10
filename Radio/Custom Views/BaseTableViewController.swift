//
//  BaseTableViewController.swift
//  Radio
//
//  Created by Alisher on 7/7/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

protocol BaseTableViewControllerDelegate {
  func showErrorAlert(with message: String)
  func showResultView(with result: Result)
}

class BaseTableViewController: UITableViewController, BaseTableViewControllerDelegate {
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
  
  private var isKeyboardPresented = false
  private var keyboardHeight: CGFloat = 0.0
  private var resultViewBottomConstraint: CGFloat {
    var constant: CGFloat = isKeyboardPresented ? keyboardHeight : 130
    
//    if !topViewController.definesPresentationContext {
//      constant -= 60
//    }
    
    return constant
  }
    
  func showResultView(with result: Result) {
    resultView.result = result
    setupResultView()
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
  }
  
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
  
  private func setupResultView() {
    configureResultView()
    configureResultConstraints()
  }
  
  private func configureResultView() {
    topViewController.view.addSubview(resultView)
    
  }
  
  private func configureResultConstraints() {
    NSLayoutConstraint.activate([
      resultView.bottomAnchor.constraint(
        equalTo: topViewController.view.safeAreaLayoutGuide.bottomAnchor,
        constant: -resultViewBottomConstraint),
      resultView.leadingAnchor.constraint(equalTo: topViewController.view.leadingAnchor,
                                          constant: 16.0),
      resultView.trailingAnchor.constraint(equalTo: topViewController.view.trailingAnchor,
                                           constant: -16.0),
      resultView.heightAnchor.constraint(equalToConstant: 40.0)
    ])
    
    showHideWithAnimation()
  }
  
  private func showHideWithAnimation() {
    UIView.animate(withDuration: 0.4,
                   animations: {
                    self.resultView.alpha = 1.0
                    self.resultView.isHidden = false
    }) { (_) in
      self.resultView.alpha = 1.0
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
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
    isKeyboardPresented = true
    keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
    view.layoutIfNeeded()
  }

  @objc private func keyboardWillHide(_ notification: Notification) {
    isKeyboardPresented = false
    keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
    view.layoutIfNeeded()
  }
    
}

extension BaseTableViewController: InteractorOutputProtocol {
  func handleError(_ error: Error, _ result: Result?) {
    if let result = result {
      showResultView(with: result)
    } else {
      showErrorAlert(with: error.localizedDescription)
    }
  }
}
