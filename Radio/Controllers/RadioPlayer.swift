//
//  Player.swift
//  Radio
//
//  Created by Alisher on 8/13/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

final class RadioPlayer: NSObject, AVPlayerItemMetadataOutputPushDelegate {
  @objc enum RadioPlayerState: Int {
    case loading
    case playing
    case stoped
    case fail
  }
  
  // MARK: - Properties
  static var shared: RadioPlayer = {
    let radioPlayer = RadioPlayer()
    radioPlayer.setupMediaPlayer()
    radioPlayer.setupNotificationCenter()
    return radioPlayer
  }()
  
  private var playerItemContext = 0
  
  @objc dynamic var currentRadio: Radio? {
    didSet(newValue)  {
      if state == .playing {
        playerItem.asset.cancelLoading()
      }
      
      guard let radio = currentRadio else {
        return
      }
      
      let scc = MPRemoteCommandCenter.shared()
      scc.previousTrackCommand.isEnabled = radio.prevStation != nil
      scc.nextTrackCommand.isEnabled = radio.nextStation != nil
      
      track = Track(trackName: currentRadio?.name ?? NSLocalizedString("Станция", comment:  "Станция"),
                    artistName: " ",
                    trackCover: currentRadio?.logo)
    }
  }
  
  @objc dynamic var state: RadioPlayerState = .stoped {
    didSet {
      switch state {
      case .loading:
        print("Player Loading")
      case .playing:
        print("Player Playing")
      case .stoped:
        print("Player Stopped")
      case .fail:
        print("Player Fail")
      }
    }
  }
  @objc dynamic var track = Track(trackName: NSLocalizedString("Не воспроизводится",
                                  comment: "Не воспроизводится"),
                                  artistName: " ") {
    didSet {
      updateInfoCenter()
    }
  }
    
  // MARK: - Private Properties
  private var player = AVPlayer()
  private var playerItem: AVPlayerItem!
  private var metadataOutput: AVPlayerItemMetadataOutput!
  private var metadataCollector: AVPlayerItemMetadataCollector!
  
  // MARK: - LifeCycle
  private override init() {
    super.init()
    setupMediaPlayer()
    setupNotificationCenter()
  }
  
  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    
    guard context == &playerItemContext else {
      super.observeValue(forKeyPath: keyPath,
                         of: object,
                         change: change,
                         context: context)
      return
    }
    
    if keyPath == #keyPath(AVPlayerItem.status) {
      let status: AVPlayerItem.Status
      if let statusNumber = change?[.newKey] as? NSNumber {
        status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
      } else {
        status = .unknown
      }
      
      // Switch over status value
      switch status {
      case .readyToPlay:
        state = .playing
        break
      case .failed:
        state = .fail
        stopRadio()
        break
      case .unknown:
        break
      @unknown default:
        break
      }
    }
  }
  
  // MARK: - Setup
  private func updateInfoCenter() {
    let mpic = MPNowPlayingInfoCenter.default()
    let defaultImage = UIImage(named: "default-2")!
    let artwork = MPMediaItemArtwork(boundsSize: defaultImage.size) { (_) -> UIImage in
      return defaultImage
    }
    mpic.nowPlayingInfo = [
      MPMediaItemPropertyArtist: track.artistName,
      MPMediaItemPropertyTitle: track.trackName,
      MPNowPlayingInfoPropertyIsLiveStream: true,
      MPMediaItemPropertyArtwork: artwork
    ]
  }
  
  private func setupMediaPlayer() {
    let scc = MPRemoteCommandCenter.shared()
    scc.pauseCommand.isEnabled = false
    scc.previousTrackCommand.addTarget(self, action: #selector(doPrev))
    scc.nextTrackCommand.addTarget(self, action: #selector(doNext))
    scc.nextTrackCommand.isEnabled = false
    scc.previousTrackCommand.isEnabled = false
    scc.playCommand.addTarget(self, action: #selector(doPlay))
    scc.stopCommand.addTarget(self, action: #selector(doPause))
  }
  
  private func setupNotificationCenter() {
    NotificationCenter.default.addObserver(
      forName: AVAudioSession.interruptionNotification,
      object: nil,
      queue: nil) { (n) in
        let why = n.userInfo![AVAudioSessionInterruptionTypeKey] as! UInt
        let type = AVAudioSession.InterruptionType(rawValue: why)
        switch type {
        case .began:
          self.stopRadio()
          break
        case .ended:
          try? AVAudioSession.sharedInstance().setActive(true)
          guard let opt = n.userInfo![AVAudioSessionInterruptionOptionKey] as? UInt else {
            return
          }
          
          if AVAudioSession.InterruptionOptions(rawValue: opt).contains(.shouldResume) {
            self.playRadio()
            break
          }
        case .none: break
        @unknown default: fatalError()
        }
    }
    
    NotificationCenter.default.addObserver(forName: .AVPlayerItemPlaybackStalled,
                                           object: nil,
                                           queue: nil) { (_) in
                                            self.state = .fail
                                            self.stopRadio()
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

  
  // MARK: - Methods
  func playRadio() {
    player.isMuted = true
    state = .loading
    prepareToPlay { (isSucess) in
      if isSucess {
        self.player.isMuted = false
        self.state = .playing
        self.player.play()
      } else {
        self.state = .fail
      }
    }
  }
  
  func stopRadio() {
    player.pause()
    if state != .fail {
      state = .stoped
    }
  }
  
  // MARK: - Private Methods
  func nextStation() {
    currentRadio = currentRadio?.nextStation
    if state == .playing {
      playRadio()
    }
  }
  
  func prevStation() {
    currentRadio = currentRadio?.prevStation
    if state == .playing {
      playRadio()
    }
  }
  
  func prepareToPlay(completion: @escaping (Bool) -> ()) {
    guard
      let radio = currentRadio,
      let urlString = radio.url,
      let audioFileURL = URL(string: urlString)
    else {
      completion(false)
      return
    }
    
    player.replaceCurrentItem(with: nil)
    loadFrom(audioFileURL) { [weak self] (status, asset) in
      if status == .loaded {
        self?.setupPlayerWith(asset)
        completion(true)
      } else if status == .failed {
        completion(false)
      }
    }
  }
  
  func loadFrom(_ url: URL,
                completion: @escaping (_ status: AVKeyValueStatus, _ asset: AVAsset) -> Void) {
    let playableKey = "playable"
    let asset = AVAsset(url: url)
    asset.loadValuesAsynchronously(forKeys: [playableKey]) {
      var error: NSError? = nil
      let status = asset.statusOfValue(forKey: playableKey, error: &error)
      completion(status, asset)
    }
  }
  
  func setupPlayerWith(_ asset: AVAsset) {
    metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
    metadataOutput.setDelegate(self, queue: DispatchQueue.main)
    playerItem = AVPlayerItem(asset: asset)
    playerItem.preferredForwardBufferDuration = TimeInterval(UserDefaults.standard.double(forKey: "BufferSize"))
    player.automaticallyWaitsToMinimizeStalling = true
    playerItem.addObserver(self,
                                forKeyPath: #keyPath(AVPlayerItem.status),
                                options: [.old, .new],
                                context: &self.playerItemContext)
    playerItem.add(self.metadataOutput)
    player = AVPlayer(playerItem: self.playerItem)
  }
    
  // MARK: - Private Actions
  @objc func doPrev(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    prevStation()
    return .success
  }
  
  @objc func doNext(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
    nextStation()
    return .success
  }
  
  @objc private func doPlayPause(_ event:MPRemoteCommandEvent)
    -> MPRemoteCommandHandlerStatus {
      switch state {
      case .playing:
        stopRadio()
      case .stoped:
        playRadio()
      default:
        break
      }
      
      return .success
  }
  
  @objc private func doPlay(_ event:MPRemoteCommandEvent)
    -> MPRemoteCommandHandlerStatus {
      playRadio()
      return .success
  }
  
  @objc private func doPause(_ event:MPRemoteCommandEvent)
    -> MPRemoteCommandHandlerStatus {
      stopRadio()
      return .success
  }
  
  func metadataOutput(_ output: AVPlayerItemMetadataOutput,
                       didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
                       from track: AVPlayerItemTrack?) {
     let item = groups.first?.items.first
     if let items = item?.value(forKey: "value") as? String {
       let parts = items.components(separatedBy: " - ")

       guard
         let artistName = parts.first,
         let trackName = parts.last,
         artistName != "",
         trackName != ""
       else {
         return
       }

      self.track = Track(trackName: trackName,
                         artistName: artistName,
                         trackCover: currentRadio?.logo)
     }
   }
}
