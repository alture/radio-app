//
//  EmptyView.swift
//  Radio
//
//  Created by Alisher on 8/12/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

protocol EmptyViewDelegate {
  func didTapButton()
}

struct EmptyViewModel {
  var title: String
  var buttonTitle: String
}

final class EmptyView: UIView {
  
  // MARK: - Properties
  var delegate: EmptyViewDelegate?
  var model: EmptyViewModel? {
    didSet {
      guard let model = model else {
        return
      }
      
      title.text = model.title
      button.setTitle(model.buttonTitle, for: .normal)
      title.sizeToFit()
      button.sizeToFit()
    }
  }
  
  // MARK: - Private Properties
  private lazy var title: UILabel = {
    let label = UILabel(frame: .zero)
    label.textColor = UIColor.systemGray4
    label.textAlignment = .center
    return label
  }()
  
  private lazy var button: UIButton = {
    let button = UIButton(type: .system)
    button.tintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
    button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    return button
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.axis = .vertical
    stackView.spacing = 8.0
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  // MARK: - Lifecycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func setupView() {
    configureViews()
    configureConstraints()
  }
  
  private func configureViews() {
    stackView.addArrangedSubview(title)
    stackView.addArrangedSubview(button)
    addSubview(stackView)
  }
  
  private func configureConstraints() {
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
  
  // MARK: - Private actions
  @objc private func didTapButton() {
    delegate?.didTapButton()
  }
}
