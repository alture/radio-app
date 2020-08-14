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

protocol RadioPlayerDelegate {
  
}

final class RadioPlayer {
  
  // MARK: - Properties
  static func shared() -> RadioPlayer {
    return RadioPlayer()
  }
  
  var currentRadio: Radio?
  var delegate: RadioPlayerDelegate?
  var parentVC: AVPlayerItemMetadataOutputPushDelegate!
  
  // MARK: - Private Properties
  private var player = AVPlayer()
  private var playerItem: AVPlayerItem!
  private var metadataOutput: AVPlayerItemMetadataOutput!
  
  
  // MARK: - LifeCycle
  init() {}
  
  // MARK: - Setup
  
  private func setupMediaPlayer() {
    let scc = MPRemoteCommandCenter.shared()
    scc.playCommand.addTarget(self, action:#selector(doPlay))
    scc.pauseCommand.addTarget(self, action:#selector(doPause))
    scc.togglePlayPauseCommand.addTarget(self, action: #selector(doPlayPause))
  }
  
  // MARK: - Methods
  func prepareToPlay() -> Bool  {
    guard
      let radio = currentRadio,
      let url = radio.url,
      let audioStreamURL = URL(string: url)
    else {
      player.pause()
      return false
    }
    
    let asset = AVAsset(url: audioStreamURL)
    metadataOutput = AVPlayerItemMetadataOutput()
    metadataOutput.setDelegate(parentVC, queue: DispatchQueue.main)
    
    playerItem = AVPlayerItem(asset: asset)
    playerItem.preferredForwardBufferDuration = TimeInterval(UserDefaults.standard.double(forKey: "BufferSize"))
    
    return true
  }
  
  // MARK: - Actions
  
  // MARK: - Private Actions
  @objc private func doPlayPause(_ event:MPRemoteCommandEvent)
    -> MPRemoteCommandHandlerStatus {
      return .success
  }
  
  @objc private func doPlay(_ event:MPRemoteCommandEvent)
    -> MPRemoteCommandHandlerStatus {
      prepareToPlay() ? .success : .noSuchContent
  }
  
  @objc private func doPause(_ event:MPRemoteCommandEvent)
    -> MPRemoteCommandHandlerStatus {
      player.pause()
      return .success
  }
}


// MARK: - AVPlayerItemMetadataOutputPushDelegate
