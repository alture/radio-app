//
//  RadioFilterViewController.swift
//  Radio
//
//  Created by Alisher on 6/30/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import RealmSwift

protocol RadioFilterViewControllerDelegate {
  func didTapDone()
}

final class RadioFilterViewController: BaseViewController {
  
  // MARK: Properties

  var presenter: RadioFilterPresentation?
  var delegate: RadioFilterViewControllerDelegate?
  private var filterHelper: Filter?
  
  private lazy var realm: Realm = {
    let rlm: Realm
    do {
      rlm = try Realm()
    } catch let error {
      fatalError(error.localizedDescription)
    }
    return rlm
  }()
  
  private var titleOfSections = [
    NSLocalizedString("Жанр", comment: "Жанр"),
    NSLocalizedString("Страна", comment: "Страна")
  ]
  
  private var defaultFirstRowContent = [
    NSLocalizedString("Все жанры", comment: "Все жанры"),
    NSLocalizedString("Все страны", comment: "Все страны")
  ]
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(RadioFilterCell.self, forCellReuseIdentifier: "DataCell")
    tableView.allowsMultipleSelection = true
    
    return tableView
  }()
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    setupNavigationBar()
    presenter?.viewDidLoad()
  }
  
  private func setupNavigationBar() {
    let barButtonItem = UIBarButtonItem(
      title: NSLocalizedString("Готово", comment: "Готово"),
      style: .done,
      target: self,
      action: #selector(didTapDoneButton))
    barButtonItem.tintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
    navigationItem.rightBarButtonItem = barButtonItem
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton))
  }
  
  private func setupView() {
    view.backgroundColor = UIColor.init(dynamicProvider: { (trait) -> UIColor in
      return trait.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
    })
    
    configureView()
    configureConstraints()
  }
  
  private func configureView() {
    view.addSubview(tableView)
  }
  
  private func configureConstraints() {
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }
  
  @objc private func didTapDoneButton() {    
//    navigationController?.navigationItem.rightBarButtonItem?.isSpringLoaded = true
    
    guard let lastFilterHelper = filterHelper else { return }
    lastFilterHelper.genre = lastFilterHelper[0].filter({ $0.selected })
    lastFilterHelper.country = lastFilterHelper[1].filter({ $0.selected })
    presenter?.appendNewFilter(lastFilterHelper)
  }
  
  @objc private func didTapCancelButton() {
    dismiss(animated: true)
  }
}

extension RadioFilterViewController: RadioFilterView {
  func updateViewFromModel(_ filter: Filter) {
    self.filterHelper = filter
    tableView.reloadData()
    return
  }
  
  func uploaded() {
    dismiss(animated: true) {
      self.delegate?.didTapDone()
    }
  }
}

extension RadioFilterViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return titleOfSections[section]
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    guard filterHelper != nil else {
      return 0
    }
    
    return titleOfSections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let filter = filterHelper else {
      return 0
    }
    
    return filter[section].count + 1
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = RadioFilterCell(style: .subtitle, reuseIdentifier: "DataCell")
    let section = indexPath.section, row = indexPath.row
    cell.selectionStyle = .none
    cell.tintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
    cell.detailTextLabel?.textColor = .darkGray
    
    guard let lastFilterHelper = filterHelper else {
      return cell
    }
    
    if row == 0 {
      cell.textLabel?.text = defaultFirstRowContent[section]
        if lastFilterHelper[section].filter({ $0.selected }).isEmpty {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
          }
        }
    } else {
      let filterItem = lastFilterHelper[section][row - 1]
      cell.textLabel?.text = filterItem.name
      cell.detailTextLabel?.text = "\(filterItem.stations)"
      if filterItem.selected {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
          tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
      }
    }

    return cell
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    guard indexPath.row != 0 else {
      tableView.deselectRows(at: indexPath.section)
      return indexPath
    }
    
    if let selectedRows = tableView.indexPathsForSelectedRows?.filter({ $0.section == indexPath.section }) {
      if selectedRows.count == 5 {
        prepareResultView(
          with: .warning(text: NSLocalizedString("Возможно выбрать максимум 5!",
                         comment: "Предупреждение в окне фильтра")))
        return nil
      }
    }
    
    return indexPath
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let lastFilterHelper = filterHelper else { return }
    let section = indexPath.section, row = indexPath.row
    if row == 0 {
      lastFilterHelper.deselectItems(at: section)
    } else {
      lastFilterHelper[section][row - 1].selected = true
      tableView.deselectRow(at: IndexPath(row: 0, section: section), animated: false)
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard let lastFilterHelper = filterHelper else {
      return
    }
    
    let section = indexPath.section, row = indexPath.row
    lastFilterHelper[section][row - 1].selected = false
    tableView.reloadRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .none)
  }
  
  func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
    return indexPath.row != 0 ? indexPath : nil
  }
}

