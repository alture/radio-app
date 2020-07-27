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
import Network
import StoreKit

class RadioTabBarViewController: UITabBarController {
  
  private var player = AVPlayer()
  private var playerItem: AVPlayerItem!
  private var metadataOutput: AVPlayerItemMetadataOutput!
  
  private var monitor = NWPathMonitor()
  private var queue = DispatchQueue(label: "Monitor")
  
  private var playerInfo: PlayerInfo? {
    didSet {
      guard let playerInfo = playerInfo else {
        return
      }
      
      if radioPlayerVC.isViewLoaded {
        radioPlayerVC.playerInfo = playerInfo
        radioPlayerVC.configure()
      }
    }
  }
  
  var radioPlayerVC = RadioPlayerRouter.setupModule()
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
    radioPlayerVC.delegate = self
    setupView()
    configureNotificationCenter()
    setupMediaPlayer()
    
    tabBar.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    setupMonitor()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
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
      radioInfoView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 1)
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
    
    NotificationCenter.default.addObserver(forName: .AVPlayerItemPlaybackStalled,
                                           object: nil,
                                           queue: nil) { (_) in
                                            print("PlaybackIsStalled")
                                            self.pauseStream()
                                            self.isPlaying = false
                                            
                  
    }
    
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                           object: nil,
                                           queue: nil) { (_) in
                                            print("AVPlayerItemDidPlayToEndTime")
                                            
                  
    }
    
    NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime,
                                           object: nil,
                                           queue: nil) { (_) in
                                            print("AVPlayerItemFailedToPlayToEndTime")
                                            
                  
    }
  }
  
  private func setupMonitor() {
    monitor.start(queue: queue)
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
    if isPlaying == false {
      prepareToPlay()
    }
    
    isPlaying = true
    playerInfo?.isPlaying = isPlaying
    player.play()
  }
  
  func pauseStream() {
    isPlaying = false
    playerInfo?.isPlaying = isPlaying
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
    metadataOutput = AVPlayerItemMetadataOutput()
    metadataOutput.setDelegate(self, queue: DispatchQueue.main)
    
    playerItem = AVPlayerItem(asset: asset)
    playerItem.add(metadataOutput)
    
    player.replaceCurrentItem(with: playerItem)
    radioInfoView.titleLabel.text = radio.name
    if let radioLogoString = radio.logo {
      radioInfoView.logoImageView.load(radioLogoString)
    } else {
      radioInfoView.logoImageView.image = UIImage(named: "logo")
    }
    
    playerInfo = PlayerInfo(title: currentRadio?.name ?? "Загружается",
                            author: "",
                            image: radioInfoView.logoImageView.image,
                            isPlaying: isPlaying)
  }
}

extension RadioTabBarViewController: AVPlayerItemMetadataOutputPushDelegate {
  func metadataOutput(_ output: AVPlayerItemMetadataOutput,
                      didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
                      from track: AVPlayerItemTrack?) {
    let item = groups.first?.items.first
    if let items = item?.value(forKey: "value") as? String {
      let parts = items.components(separatedBy: " - ")

      radioInfoView.titleLabel.text = parts.last
      
      let artistName = parts.first ?? ""
      let titleName = parts.last ?? currentRadio?.name ?? "Загружается"
      
      playerInfo = PlayerInfo(title: artistName,
                              author: titleName,
                              image: radioInfoView.logoImageView.image,
                              isPlaying: isPlaying)
      
      let mpic = MPNowPlayingInfoCenter.default()
      mpic.nowPlayingInfo = [
          MPMediaItemPropertyArtist: artistName,
          MPMediaItemPropertyTitle: titleName,
      ]
    }
  }
}

extension RadioTabBarViewController: RadioInfoViewDelegate {
  func showPlayer() {
    radioPlayerVC.playerInfo = playerInfo
    radioPlayerVC.player = player
    present(radioPlayerVC, animated: true)
  }
  
  func didTapPlayButton() {
    if isPlaying {
      pauseStream()
    } else {
      playStream()
    }
  }
}

extension RadioTabBarViewController: RadioPlayerViewControllerDelegate {
  func didTapPlayStopButton() {
    if isPlaying {
      pauseStream()
    } else {
      playStream()
    }
  }
}
