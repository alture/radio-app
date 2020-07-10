//
//  RadioFilterViewController.swift
//  Radio
//
//  Created by Alisher on 6/30/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

protocol RadioFilterViewControllerDelegate {
  func didTapShowWithFilter(filter values: FilteredValues)
  func didTapAppendFilters(_ genres: [Genre], _ countries: [Country])
}

final class RadioFilterViewController: BaseViewController {
  
  // MARK: Properties
  
  var delegate: RadioFilterViewControllerDelegate?
  var filterValues: FilteredValues?
  
  var presenter: RadioFilterPresentation?
  private var genries: [Genre] = []
  private var countries: [Country] = []
  
  private var selectedGenries: [Genre] = []
  private var selectedCountries: [Country] = []
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
    
    presenter?.viewDidLoad()
    setupView()
    setupNavigationBar()
  }

  private func setupNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Done",
      style: .done,
      target: self,
      action: #selector(didTapDoneButton))
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
    dismiss(animated: true) {
      self.delegate?.didTapAppendFilters(self.selectedGenries, self.selectedCountries)
    }
  }
}

extension RadioFilterViewController: RadioFilterView {
  func updateViewFromModel(_ genre: [Genre], _ country: [Country]) {
    genries = genre
    countries = country
    tableView.beginUpdates()
    tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    tableView.endUpdates()
    tableView.selectRow(at: IndexPath(row: 0, section: 0),
                        animated: false,
                        scrollPosition: .none)
    tableView.selectRow(at: IndexPath(row: 0, section: 1),
                        animated: false,
                        scrollPosition: .none)
    return
  }
}

extension RadioFilterViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return "Жанр"
    case 1: return "Страна"
    default:
      return nil
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (section == 0 ? genries.count : countries.count) + 1
  }

  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! RadioFilterCell
    cell.selectionStyle = .none
    if indexPath.row == 0 {
      cell.textLabel?.text = indexPath.section == 0
        ? "Все жанры"
        : "Все страны"
    } else {
      cell.textLabel?.text = indexPath.section == 0
        ? genries[indexPath.row-1].name
        : countries[indexPath.row-1].name
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row != 0 && selectedGenries.count > 5 || selectedCountries.count > 5 {
      showResultView(with: .warning(text: "Возможно выбрать максимум 5!"))
      tableView.deselectRow(at: indexPath, animated: false)
      return
    }
    
    
    if indexPath.row == 0 {
      tableView.deselectAll(except: indexPath.row, at: indexPath.section)

      if indexPath.section == 0 {
        selectedGenries = []
      } else {
        selectedCountries = []
      }
    } else {
      tableView.deselectRow(at: IndexPath(row: 0, section: indexPath.section), animated: true)
      if indexPath.section == 0 {
        selectedGenries.append(genries[indexPath.row - 1])
      } else {
        selectedCountries.append(countries[indexPath.row - 1])
      }
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard indexPath.row != 0 else {
      tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
      return
    }
      
    if indexPath.section == 0 {
      if let indexOfItem = selectedGenries.firstIndex(of: genries[indexPath.row - 1]) {
        selectedGenries.remove(at: indexOfItem)
      }
    } else {
      if let indexOfItem = selectedCountries.firstIndex(of: countries[indexPath.row - 1]) {
        selectedCountries.remove(at: indexOfItem)
      }
    }
  }
}

extension UITableView {
  func deselectAll(except index: Int, at section: Int) {
    guard let indexPathsForSelectedRows = indexPathsForSelectedRows else {
      return
    }
    
    for indexPath in indexPathsForSelectedRows {
      if indexPath.row != index {
        deselectRow(at: IndexPath(row: indexPath.row, section: section), animated: false)
      }
    }
  }
}
