//
//  RadioPlayerViewController.swift
//  Radio
//
//  Created by Alisher on 7/11/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

final class RadioPlayerViewController: BaseViewController {
  
  // MARK: Properties
  @objc dynamic var radioPlayer = RadioPlayer.shared
  var observations = [NSKeyValueObservation]()
  
  var presenter: RadioPlayerPresentation?
  private lazy var hiddenSystemVolumeSlider: UISlider = {
    let slider = UISlider(frame: .zero)
    return slider
  }()

  private var isPlaying: Bool = false {
    didSet {
      DispatchQueue.main.async {
        self.playStopButton?.image = UIImage(systemName: self.isPlaying
        ? "stop.fill"
        : "play.fill")
      }
    }
  }
  
  private var bufferSizes = [
    NSLocalizedString("АВТО", comment: "Размер буфера"),
    NSLocalizedString("5 секунд", comment: "Размер буфера"),
    NSLocalizedString("10 секунд", comment: "Размер буфера"),
    NSLocalizedString("60 секунд", comment: "Размер буфера")]
  private var bufferSize: Double = 0
  
  private lazy var volumeView: MPVolumeView = {
    let volumeView = MPVolumeView(frame: CGRect(x: -200, y: -200, width: 0.0, height: 0.0))
    hiddenSystemVolumeSlider = volumeView.subviews.first(where: { $0 is UISlider }) as! UISlider
    return volumeView
  }()
  
  private lazy var pickerView: UIPickerView = {
    let view = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
    view.delegate = self
    view.dataSource = self
    return view
  }()
  @IBOutlet weak var volumeSlider: UISlider!
  @IBAction func didChangeSliderValue(_ sender: UISlider) {
    let changedValue = Float(sender.value)
    hiddenSystemVolumeSlider.value = changedValue
    
  }
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.layer.cornerRadius = 8.0
      containerView.clipsToBounds = false
    }
  }
  @IBOutlet weak var imageView: UIImageView! {
    didSet {
      imageView.layer.cornerRadius = 8.0
      imageView.clipsToBounds = true
    }
  }
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var authorNameLabel: UILabel!
  @IBOutlet weak var plusImageView: UIImageView! {
    didSet {
      let tap = UITapGestureRecognizer(target: self,
                                       action: #selector(didTapOption))
      plusImageView.addGestureRecognizer(tap)
    }
  }
  @IBOutlet weak var playStopButton: UIImageView! {
    didSet {
      let tap = UITapGestureRecognizer(target: self,
                                       action: #selector(didTapPlayStopButton))
      playStopButton.addGestureRecognizer(tap)
    }
  }
  
  @IBOutlet weak var prevButtonImage: UIImageView! {
    didSet {
      let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPrevButton))
      prevButtonImage.addGestureRecognizer(tap)
    }
  }
  @IBOutlet weak var nextButtonImage: UIImageView! {
    didSet {
      let tap = UITapGestureRecognizer(target: self, action: #selector(didTapNextButton))
      nextButtonImage.addGestureRecognizer(tap)
    }
  }
  
  private func updateControls() {
    let scc = MPRemoteCommandCenter.shared()
    var isEnabled = scc.previousTrackCommand.isEnabled
    prevButtonImage.isUserInteractionEnabled = isEnabled
    prevButtonImage.alpha = isEnabled ? 1.0 : 0.3

    isEnabled = scc.nextTrackCommand.isEnabled
    nextButtonImage.isUserInteractionEnabled = isEnabled
    nextButtonImage.alpha = isEnabled ? 1.0 : 0.3

    isEnabled = radioPlayer.currentRadio != nil
    playStopButton.isUserInteractionEnabled = isEnabled
    playStopButton.alpha = isEnabled ? 1.0 : 0.3
    
    switch radioPlayer.state {
    case .playing, .loading:
      isPlaying = true
    case .stoped, .fail:
      isPlaying = false
    }
  }
  
  private func updateLabels() {
    let player = RadioPlayer.shared
    trackNameLabel.text = player.track.trackName
    authorNameLabel.text = player.track.artistName
    imageView.image = nil
    imageView.cancelImageLoading()
    if
      let logo = player.track.trackCover,
      let url = URL(string: logo) {
      imageView.loadImage(at: url)
    } else {
      imageView.image = UIImage(named: "default-2")
    }
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(volumeView)
    observations = [
      radioPlayer.observe(\.currentRadio,
                          options: [.new, .old],
                          changeHandler: { (player, value) in
                            DispatchQueue.main.async {
                              if let radio = player.currentRadio {
                                let currentImageName = radio.isFavorite
                                  ? "checkmark"
                                  : "plus"
                                self.plusImageView.image = UIImage(systemName: currentImageName)
                              }
                              self.updateControls()
                            }
      }),
      radioPlayer.observe(\.track,
                          options: [.new, .old],
                          changeHandler: { (player, value) in
                            DispatchQueue.main.async {
                              self.updateLabels()
                            }
      }),
      radioPlayer.observe(\.state,
                          options: [.initial],
                          changeHandler: { (player, value) in
                            DispatchQueue.main.async {
                              switch player.state {
                              case .playing, .loading: self.isPlaying = true
                              case .stoped: self.isPlaying = false
                              case .fail: self.showErrorAlert(with: NSLocalizedString("Не удается воспроизвести поток", comment: "Ошибка в плеере"))
                              }
                            }
      })]
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
        
    let audioSession = AVAudioSession.sharedInstance()
    audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
    volumeSlider.value = audioSession.outputVolume
    updateLabels()
    updateControls()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    let audioSession = AVAudioSession.sharedInstance()
    audioSession.removeObserver(self, forKeyPath: "outputVolume")
  }
  
  override func viewDidLayoutSubviews() {
    containerView.layer.shadowPath =
          UIBezierPath(roundedRect: containerView.bounds,
                       cornerRadius: 8.0).cgPath
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOpacity = 0.2
    containerView.layer.shadowOffset = CGSize.zero
    containerView.layer.shadowRadius = 10.0
    containerView.layer.masksToBounds = false
    containerView.backgroundColor = .red
  }
  
  @objc private func didTapPlayStopButton() {
    if isPlaying {
      radioPlayer.stopRadio()
    } else {
      radioPlayer.playRadio()
    }
  }
  
  @objc private func didTapOption() {
    if let currentRadio = RadioPlayer.shared.currentRadio {
      if currentRadio.isFavorite {
        currentRadio.isFavorite = false
        plusImageView.image = UIImage(systemName: "plus")
        presenter?.didTapRemoveFromFavorite(with: currentRadio.id)
      } else {
        currentRadio.isFavorite = true
        plusImageView.image = UIImage(systemName: "checkmark")
        presenter?.didTapAddToFavorite(with: currentRadio.id)
        handleError(nil, .sucess(text: NSLocalizedString("Добавлено в Мои станции", comment: "В плеере")))
      }
      
    }
  }
  
  @objc private func didTapPrevButton() {
    radioPlayer.prevStation()
  }
  
  @objc private func didTapNextButton() {
    radioPlayer.nextStation()
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "outputVolume" {
      let outputValue = AVAudioSession.sharedInstance().outputVolume
      volumeSlider.setValue(outputValue, animated: true)
    }
  }
}

extension RadioPlayerViewController: RadioPlayerView {
  func radioAdded() {
//    prepareResultView(with: .sucess(text: "Станция в эфире"), .showAndHide)
  }
}

extension RadioPlayerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return bufferSizes.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return bufferSizes[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch row {
    case 0: bufferSize = 0
    case 1: bufferSize = 5
    case 2: bufferSize = 10
    case 3: bufferSize = 60
    default:
      bufferSize = 0
    }
  }
}
