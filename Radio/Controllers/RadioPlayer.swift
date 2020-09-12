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
  @objc enum RadioPlayerState: Int{
    case stoped
    case playing
    case fail
  }
  
  // MARK: - Properties
  static var shared: RadioPlayer = {
    let radioPlayer = RadioPlayer()
    radioPlayer.setupMediaPlayer()
    radioPlayer.setupNotificationCenter()
    return radioPlayer
  }()
  
  @objc dynamic var currentRadio: Radio? {
    didSet(newValue)  {
      guard let radio = currentRadio else {
        return
      }
      
      let scc = MPRemoteCommandCenter.shared()
      scc.previousTrackCommand.isEnabled = radio.prevStation != nil
      scc.nextTrackCommand.isEnabled = radio.nextStation != nil
      
      track = Track(trackName: currentRadio?.name ?? "Станция",
                    artistName: " ",
                    trackCover: currentRadio?.logo)
    }
  }
  
  @objc dynamic var state: RadioPlayerState = .stoped {
    didSet {
//      track.isPlaying = state == .playing
    }
  }
  
  @objc dynamic var track = Track(trackName: "Не воспроизводится",
                                  artistName: " ") {
    didSet {
      updateInfoCenter()
    }
  }
  
  var delegate: AVPlayerItemMetadataOutputPushDelegate?
  
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
                                            print("PlaybackIsStalled")
//                                            self.pauseRadio()
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
    prepareToPlay { (isSucess) in
      if isSucess {
        self.player.isMuted = false
        self.player.play()
        self.state = .playing
      } else {
        self.state = .fail
      }
    }
  }
  
  func stopRadio() {
    player.pause()
    state = .stoped
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
      let url = radio.url,
      let audioFileURL = URL(string: url)
    else {
      completion(false)
      return
    }
    
    isPlayable(url: audioFileURL) { (status) in
      if status == true {
        let asset = AVAsset(url: audioFileURL)
        self.metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
        self.metadataOutput.setDelegate(self, queue: DispatchQueue.main)
        self.playerItem = AVPlayerItem(asset: asset)
        self.playerItem.preferredForwardBufferDuration = TimeInterval(UserDefaults.standard.double(forKey: "BufferSize"))
        self.player.automaticallyWaitsToMinimizeStalling = true
        self.playerItem.add(self.metadataOutput)
        self.player = AVPlayer(playerItem: self.playerItem)
        radio.currentUrlIndex = 0
        completion(true)
      } else {
        guard
          radio.otherUrl.count > radio.currentUrlIndex
        else {
          completion(false)
          return
        }
        
        let nextURL = radio.otherUrl[radio.currentUrlIndex].url
        radio.currentUrlIndex += 1
        self.currentRadio?.url = nextURL ?? ""
        self.prepareToPlay { status in
          completion(status)
        }
      }
    }
  }
  
  func isPlayable(url: URL, completion: @escaping (Bool) -> ()) {
      let asset = AVAsset(url: url)
      let playableKey = "playable"
      asset.loadValuesAsynchronously(forKeys: [playableKey]) {
          var error: NSError? = nil
          let status = asset.statusOfValue(forKey: playableKey, error: &error)
          let isPlayable = status == .loaded
          DispatchQueue.main.async {
              completion(isPlayable)
          }
      }
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

      self.track = Track(trackName: trackName, artistName: artistName, trackCover: currentRadio?.logo)
     }
   }
}
