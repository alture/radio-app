//
//  BadgeBarButton.swift
//  Radio
//
//  Created by Alisher on 25.11.2020.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class BadgeBarButton: UIButton {  
  private lazy var label: UILabel = {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 24.0, height: 24.0))
    label.backgroundColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
    label.textAlignment = .center
    label.clipsToBounds = true
    label.layer.cornerRadius = label.bounds.size.height / 2
    label.layer.borderWidth = 2.0
    label.layer.borderColor = UIColor.systemBackground.cgColor
    label.font = .systemFont(ofSize: 14.0, weight: .medium)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.layer.masksToBounds = true
    label.isHidden = true
    label.textColor = .white
    return label
  }()
  
  func setBadgeNumber(_ number: Int) {
    label.text = "\(number)"
    label.sizeToFit()
    label.isHidden = number == 0
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    configureViews()
    configureConstraints()
  }
  
  private func configureViews() {
    addSubview(label)
  }
  
  private func configureConstraints() {
    NSLayoutConstraint.activate([
      label.widthAnchor.constraint(equalToConstant: 24.0),
      label.heightAnchor.constraint(equalToConstant: 24.0),
      label.leftAnchor.constraint(equalTo: leftAnchor, constant: 15.0),
      label.topAnchor.constraint(equalTo: topAnchor, constant: -8.0)
    ])
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
      label.layer.borderColor = UIColor.systemBackground.cgColor
    }
  }
}
