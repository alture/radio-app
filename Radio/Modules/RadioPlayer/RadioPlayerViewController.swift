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

protocol RadioPlayerViewControllerDelegate {
  func didTapPlayStopButton()
}

final class RadioPlayerViewController: BaseViewController {
  
  // MARK: Properties
  
  var presenter: RadioPlayerPresentation?
  var delegate: RadioPlayerViewControllerDelegate?
  var playerInfo: PlayerInfo?
  private lazy var hiddenSystemVolumeSlider: UISlider = {
    let slider = UISlider(frame: .zero)
    return slider
  }()

  private var isPlaying: Bool = false {
    didSet {
      playStopButton?.image = UIImage(systemName: isPlaying
      ? "stop.fill"
      : "play.fill")
    }
  }
  
  private var bufferSizes = ["АВТО", "5 секунд", "10 секунд", "60 секунд"]
  private var bufferSize: Double = 0
  
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
  @IBOutlet weak var optionImageView: UIImageView! {
    didSet {
      let tap = UITapGestureRecognizer(target: self,
                                       action: #selector(didTapOption))
      optionImageView.addGestureRecognizer(tap)
    }
  }
  @IBOutlet weak var playStopButton: UIImageView! {
    didSet {
      let tap = UITapGestureRecognizer(target: self,
                                       action: #selector(didTapPlayStopButton))
      playStopButton.addGestureRecognizer(tap)
    }
  }
  
  // MARK: Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    configure()
    
    let audioSession = AVAudioSession.sharedInstance()
    audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
    volumeSlider.value = audioSession.outputVolume
    
    let volumeView = MPVolumeView(frame: CGRect(x: -200, y: -200, width: 0.0, height: 0.0))
    view.addSubview(volumeView)
    hiddenSystemVolumeSlider = volumeView.subviews.first(where: { $0 is UISlider }) as! UISlider
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    let audioSession = AVAudioSession.sharedInstance()
    audioSession.removeObserver(self, forKeyPath: "outputVolume")
    hiddenSystemVolumeSlider.removeFromSuperview()
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
  
  func configure() {
    guard let playerInfo = playerInfo else {
      isPlaying = false
      return
    }
    
    trackNameLabel?.text = playerInfo.title
    authorNameLabel?.text = playerInfo.author
    if let imgURL = playerInfo.image {
      imageView.load(imgURL)
    } else {
      imageView.image = UIImage(named: "default-2")
    }
    
    isPlaying = playerInfo.isPlaying
  }
  
  @objc private func didTapPlayStopButton() {
    delegate?.didTapPlayStopButton()
    isPlaying = playerInfo?.isPlaying ?? false
  }
  
  @objc private func didTapOption() {
    let vc = UIViewController()
    vc.preferredContentSize = CGSize(width: 250, height: 150)
    vc.view.addSubview(pickerView)
    
    let alertController = UIAlertController(title: "Выбора размера буффера", message: nil, preferredStyle: .alert)
    alertController.setValue(vc, forKey: "contentViewController")
    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    alertController.addAction(UIAlertAction(title: "Готово", style: .default))
    present(alertController, animated: true, completion: nil)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "outputVolume" {
      let outputValue = AVAudioSession.sharedInstance().outputVolume
      volumeSlider.setValue(outputValue, animated: true)
    }
  }
}

extension RadioPlayerViewController: RadioPlayerView {
  func updateView() {
    
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
