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
  
  private var player = AVPlayer()
  private var playerItem: AVPlayerItem!
  private var metadataOutput: AVPlayerItemMetadataOutput!
  var isPlaying: Bool = false {
    didSet {
      if isPlaying {
        radioInfoView.playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
      } else {
        radioInfoView.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
      }
    }
  }
  
  var currentRadio: Radio?
  
  private lazy var radioInfoView: RadioInfoView = {
    let view = RadioInfoView()
    view.delegate = self
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    configureNotificationCenter()
    setupMediaPlayer()
    
    tabBar.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
  }
  
  private func setupView() {
    configureViews()
    configureConstraints()
  }
  
  private func configureViews() {
    let radioListVC = RadioListRouter.setupModule()
    radioListVC.type = .favorite
    radioListVC.tabBarItem = UITabBarItem(title: "Избранное",
                                          image: UIImage(systemName: "star.fill"),
                                          tag: 0)
    
    let searchVC = RadioListRouter.setupModule()
    searchVC.type = .all
    searchVC.tabBarItem = UITabBarItem(title: "Станций",
                                       image: UIImage(systemName: "dot.radiowaves.left.and.right"),
                                       tag: 1)
    
    let settingVC = UIViewController()
    settingVC.tabBarItem = UITabBarItem(title: "Настройки",
                                        image: UIImage(systemName: "gear"),
                                        tag: 2)

    viewControllers = [
      UINavigationController(rootViewController: radioListVC),
      UINavigationController(rootViewController: searchVC),
      UINavigationController(rootViewController: settingVC)
    ]
    
    self.view.insertSubview(radioInfoView, aboveSubview: tabBar)
  }
  
  private func configureConstraints() {
    NSLayoutConstraint.activate([
      radioInfoView.heightAnchor.constraint(equalToConstant: 60.0),
      radioInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      radioInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      radioInfoView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
    ])
  }
  
  private func setupMediaPlayer() {
    let scc = MPRemoteCommandCenter.shared()
    scc.playCommand.addTarget(self, action:#selector(doPlay))
    scc.pauseCommand.addTarget(self, action:#selector(doPause))
    scc.togglePlayPauseCommand.addTarget(self, action: #selector(doPlayPause))
  }
  
  private func configureNotificationCenter() {
    NotificationCenter.default.addObserver(
      forName: AVAudioSession.interruptionNotification,
      object: nil,
      queue: nil) { (n) in
        let why = n.userInfo![AVAudioSessionInterruptionTypeKey] as! UInt
        let type = AVAudioSession.InterruptionType(rawValue: why)
        switch type {
        case .began:
          self.pauseStream()
        case .ended:
          try? AVAudioSession.sharedInstance().setActive(true)
          guard let opt = n.userInfo![AVAudioSessionInterruptionOptionKey] as? UInt else {
            return
          }
          
          if AVAudioSession.InterruptionOptions(rawValue: opt).contains(.shouldResume) {
            self.playStream()
          }
        case .none: break
        @unknown default: fatalError()
        }
    }
  }
  
  @objc func doPlayPause(_ event:MPRemoteCommandEvent)
    -> MPRemoteCommandHandlerStatus {
      if isPlaying {
        pauseStream()
      } else {
        playStream()
      }
      
      isPlaying = !isPlaying
      return .success
  }
  
  @objc func doPlay(_ event:MPRemoteCommandEvent)
    -> MPRemoteCommandHandlerStatus {
      playStream()
      return .success
  }
  
  @objc func doPause(_ event:MPRemoteCommandEvent)
    -> MPRemoteCommandHandlerStatus {
      pauseStream()
      return .success
  }
  
  func playStream() {
    isPlaying = true
    player.play()
  }
  
  func pauseStream() {
    isPlaying = false
    player.pause()
  }
  
  func prepareToPlay() {
    guard
      let radio = currentRadio,
      let url = radio.url,
      let audioFileURL = URL(string: url)
    else {
      if let parentVC = parent?.children[0] as? BaseViewController {
        parentVC.showErrorAlert(with: "Неверный поток")
      }
      
      pauseStream()
      return
    }
    
    let asset = AVAsset(url: audioFileURL)
    metadataOutput = AVPlayerItemMetadataOutput(identifiers: [
        AVMetadataIdentifier.commonIdentifierTitle.rawValue
    ])
    metadataOutput.setDelegate(self, queue: DispatchQueue.main)
    
    playerItem = AVPlayerItem(asset: asset)
    playerItem.add(metadataOutput)
    player.replaceCurrentItem(with: playerItem)
    radioInfoView.titleLabel.text = radio.name
    if
      let radioLogoString = radio.logo,
      let radioLogoURL = URL(string: radioLogoString) {
      radioInfoView.logoImageView.load(url: radioLogoURL)
    }
  }
}

extension RadioTabBarViewController: AVPlayerItemMetadataOutputPushDelegate {
  func metadataOutput(_ output: AVPlayerItemMetadataOutput,
                      didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
                      from track: AVPlayerItemTrack?) {
    
    
    if
      let group = groups.first,
      let item = group.items.first {
      let title = item.stringValue ?? "Загружается..."
      print(title)
      let mpic = MPNowPlayingInfoCenter.default()
      mpic.nowPlayingInfo = [
          MPMediaItemPropertyTitle: title,
      ]
    }
  }
}

extension RadioTabBarViewController: RadioInfoViewDelegate {
  func didTapPlayButton() {
    if isPlaying {
      pauseStream()
    } else {
      playStream()
    }
  }
}
