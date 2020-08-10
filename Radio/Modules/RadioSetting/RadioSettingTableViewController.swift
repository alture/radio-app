//
//  RadioSettingTableViewController.swift
//  Radio
//
//  Created by Alisher on 8/6/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

enum InterfaceStyle {
  case auto
  case dark
  case light
}


final class RadioSettingTableViewController: BaseTableViewController {
  
  // MARK: Properties
  
  var presenter: RadioSettingPresentation?
  var width: CGFloat {
    view.frame.width
  }
  
  private var defaults = UserDefaults.standard
  private var style: InterfaceStyle = .auto {
    didSet {
      
    }
  }
  
  private var titleSections = ["Интерфейс", "Звук", "Поддержка", "О приложений"]
  private var contentRows = [
    ["Темная тема"],
    ["Размер буфера"],
    ["Обратная связь", "Оценить"],
    [""]
  ]
  private var selectedBufferSizeIndex = 0
  private var bufferSize: [Int:Double] = [
    0:0.0,
    1:5.0,
    2:15.0,
    3:60.0
  ]
  private var bufferSizes = ["АВТО", "5 секунд", "10 секунд", "60 секунд"]
  private lazy var bottomView: UIView = {
    let view = UIView(frame: .zero)
    return view
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.alignment = .center
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.spacing = 5.0
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 2
    label.text = "Radio & Music\nv1.0"
    label.textAlignment = .center
    label.textColor = .systemGray2
    return label
  }()
  
  private lazy var imageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "logo"))
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private lazy var pickerView: UIPickerView = {
    let view = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
    view.delegate = self
    view.dataSource = self
    return view
  }()

  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupView()
    pickerView.selectedRow(inComponent: defaults.integer(forKey: "BufferSizeIndex"))
  }
  
  private func setupTableView() {
    tableView = UITableView(frame: .zero, style: .grouped)
    tableView.showsVerticalScrollIndicator = false
  }
  
  private func setupView() {
    configureViews()
    configureConstraints()
  }
  
  private func configureViews() {
    stackView.addArrangedSubviews([imageView, titleLabel])
    stackView.sizeToFit()
    bottomView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120.0)
    bottomView.addSubview(stackView)
    tableView.addSubview(bottomView)
  }
  
  private func configureConstraints() {
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
      imageView.heightAnchor.constraint(equalToConstant: 50.0),
      imageView.widthAnchor.constraint(equalToConstant: 50.0)
    ])
  }
  
  private func showBufferOption() {
    let vc = UIViewController()
    vc.preferredContentSize = CGSize(width: 250, height: 150)
    vc.view.addSubview(pickerView)
    
    let alertController = UIAlertController(title: "Выбора размера буффера", message: nil, preferredStyle: .alert)
    alertController.setValue(vc, forKey: "contentViewController")
    alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    alertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { (_) in
      self.defaults.set(self.bufferSize[self.selectedBufferSizeIndex], forKey: "BufferSize")
      self.defaults.set(self.selectedBufferSizeIndex, forKey: "BufferSizeIndex")
    }))
    present(alertController, animated: true, completion: nil)
  }
  
  private func showEmail() {
    guard MFMailComposeViewController.canSendMail() else {
        print("This device doesn't allow you to send mail.")
        return
    }
    let toRecipients = ["ar@rvision.tv"]
    
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setToRecipients(toRecipients)
    present(mailComposer, animated: true, completion: nil)
  }
  
  @objc private func didChange(_ sender: UISwitch) {
    defaults.set(sender.isOn, forKey: "DarkMode")
    switchToInterfaceStyle(sender.isOn ? .dark : .light)
  }
  
  private func switchToInterfaceStyle(_ style: UIUserInterfaceStyle ) {
    UIApplication.shared.windows.forEach { window in
      window.overrideUserInterfaceStyle = style
    }
  }
  
}

extension RadioSettingTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return titleSections.count
  }
  
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return contentRows[section].count
  }
  
  override func tableView(_ tableView: UITableView,
                          titleForHeaderInSection section: Int) -> String? {
    return titleSections[section]
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
    cell.textLabel?.text = contentRows[indexPath.section][indexPath.row]
    cell.selectionStyle = .none
    
    switch indexPath.section {
    case 0:
      if indexPath.row == 0 {
        let switchControl = UISwitch(frame: .zero)
        switchControl.onTintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
        switchControl.setOn(defaults.bool(forKey: "DarkMode"), animated: false)
        switchControl.addTarget(self, action: #selector(didChange(_:)), for: .valueChanged)
        cell.accessoryView = switchControl
      }
    case 1...2:
      if indexPath.row == 0 {
        cell.accessoryType = .disclosureIndicator
      }
    case 3:
      cell.addSubview(stackView)
      NSLayoutConstraint.activate([
        stackView.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
        stackView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
        cell.heightAnchor.constraint(equalToConstant: 120.0)
      ])
    default:
      break
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
    case 0:
      break
    case 1:
      if indexPath.row == 0 {
        showBufferOption()
      }
    case 2:
      if indexPath.row == 0 {
        showEmail()
      } else {
        SKStoreReviewController.requestReview()
      }
    default:
      break
    }
  }
}

extension RadioSettingTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
    selectedBufferSizeIndex = component
  }
}

extension RadioSettingTableViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController,
                             didFinishWith result: MFMailComposeResult,
                             error: Error?) {
    switch result {
    case .cancelled:
        break
    case .saved:
        break
    case .sent:
        handleError(error, .sucess(text: "Отзыв был отправлен!"))
    case MFMailComposeResult.failed:
        handleError(error, nil)
    @unknown default:
      fatalError(error?.localizedDescription ?? "")
    }
    
    dismiss(animated: true, completion: nil)
  }
}


extension RadioSettingTableViewController: RadioSettingView {
  // TODO: implement view output methods
}
