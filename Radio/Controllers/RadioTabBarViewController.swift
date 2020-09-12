//
//  RadioTabBarViewController.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class RadioTabBarViewController: UITabBarController {
  @objc dynamic var radioPlayer: RadioPlayer = RadioPlayer.shared
  private var observations = [NSKeyValueObservation]()
  private lazy var radioPlayerVC: RadioPlayerViewController = {
    let viewController = RadioPlayerRouter.setupModule()
    return viewController
  }()
  
  private lazy var radioInfoView: RadioInfoView = {
    let view = RadioInfoView()
    view.delegate = self
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupObservers()
    setupView()
    tabBar.tintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
  }
  
  private func setupObservers() {
    observations = [
      radioPlayer.observe(\.track,
                          options: .initial,
                          changeHandler: { (player, value) in
                            let track = player.track
                            self.radioInfoView.track = track
      }),
      radioPlayer.observe(\.state,
                          options: .initial,
                          changeHandler: { (player, value) in
                            self.radioInfoView.isPlaying = player.state == .playing
      })
    ]
  }
  
  private func setupView() {
    configureViews()
    configureConstraints()
  }
  
  private func configureViews() {
    let radioListVC = RadioListRouter.setupModule()
    radioListVC.type = .favorite
    radioListVC.radioPlayer = radioPlayer
    
    radioListVC.tabBarItem = UITabBarItem(title: "Избранное",
                                          image: UIImage(systemName: "star.fill"),
                                          tag: 0)
    
    let searchVC = RadioListRouter.setupModule()
    searchVC.type = .all
    searchVC.radioPlayer = radioPlayer
    searchVC.tabBarItem = UITabBarItem(title: "Станции",
                                       image: UIImage(systemName: "dot.radiowaves.left.and.right"),
                                       tag: 1)
    
    let settingVC = RadioSettingRouter.setupModule()
    settingVC.title = "Настройки"
    settingVC.tabBarItem = UITabBarItem(title: "Настройки",
                                        image: UIImage(systemName: "gear"),
                                        tag: 2)
    
    viewControllers = [
      UINavigationController(rootViewController: radioListVC),
      UINavigationController(rootViewController: searchVC),
      UINavigationController(rootViewController: settingVC)
    ]
    
    view.insertSubview(radioInfoView, aboveSubview: tabBar)
  }
  
  private func configureConstraints() {
    NSLayoutConstraint.activate([
      radioInfoView.heightAnchor.constraint(equalToConstant: 60.0),
      radioInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      radioInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      radioInfoView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 1)
    ])
  }
  
}

extension RadioTabBarViewController: RadioInfoViewDelegate {
  func showPlayer() {
    present(radioPlayerVC, animated: true)
  }
  
  func didTapPlayButton() {    
    if radioPlayer.state == .playing {
      radioPlayer.stopRadio()
    } else {
      radioPlayer.playRadio()
    }
  }
}
