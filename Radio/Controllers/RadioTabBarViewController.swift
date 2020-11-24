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
                            switch player.state {
                            case .loading:
                              self.radioInfoView.isLoading = true
                              self.radioInfoView.isPlaying = true
                            case .playing:
                              self.radioInfoView.isPlaying = true
                              self.radioInfoView.isLoading = false
                            case .stoped:
                              self.radioInfoView.isPlaying = false
                              self.radioInfoView.isLoading = false
                            case .fail:
                              self.radioInfoView.isPlaying = false
                              self.radioInfoView.isLoading = false
                              // Error handle
                              break
                            }
                            
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
    radioListVC.title = NSLocalizedString("Мои станции", comment: "Заголовок")
    radioListVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Избранное", comment: "Владки"),
                                          image: UIImage(systemName: "star.fill"),
                                          tag: 0)
    
    let searchVC = RadioListRouter.setupModule()
    searchVC.type = .all
    searchVC.radioPlayer = radioPlayer
    searchVC.title = NSLocalizedString("Cтанции", comment: "Заголовок")
    searchVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Станции", comment: "Владки"),
                                       image: UIImage(systemName: "dot.radiowaves.left.and.right"),
                                       tag: 1)
    
    let settingVC = RadioSettingRouter.setupModule()
    settingVC.title = NSLocalizedString("Настройки", comment: "Владки")
    settingVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Настройки", comment: "Настройки"),
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
    switch radioPlayer.state {
    case .playing, .loading:
      radioPlayer.stopRadio()
    case .stoped:
      radioPlayer.playRadio()
    case .fail:
      break
    }
  }
}
