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
}

final class RadioFilterViewController: BaseViewController {
  
  // MARK: Properties
  
  var selectedIndexes: (genre: [Int], country: [Int]) = ([0], [0])
  var delegate: RadioFilterViewControllerDelegate?
  
  var presenter: RadioFilterPresentation?
  private var genries: [Genre] = []
  private var countries: [Country] = []
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
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    
    var filteredValues: FilteredValues = ([], [])
    tableView.indexPathsForSelectedRows?.forEach({ (indexPath) in
      if indexPath.row == 0 {
        return
      }
      
      if indexPath.section == 0 {
        filteredValues.genriesID.append(genries[indexPath.row].id ?? 0)
      } else {
        filteredValues.countriesID.append(countries[indexPath.row].id ?? 0)
      }
    })
    
    delegate?.didTapShowWithFilter(filter: filteredValues)
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
}

extension RadioFilterViewController: RadioFilterView {
  func updateViewFromModel(_ genre: [Genre], _ country: [Country]) {
    genries = genre
    countries = country
    tableView.reloadData()
    
    selectedIndexes.genre.forEach { (index) in
      tableView.selectRow(at: IndexPath(row: index, section: 0),
                          animated: false,
                          scrollPosition: .none)
    }

    selectedIndexes.country.forEach { (index) in
      tableView.selectRow(at: IndexPath(row: index, section: 1),
      animated: false,
      scrollPosition: .none)
    }
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
    if indexPath.row == 0 {
      tableView.deselectAll()
    } else {
      tableView.deselectRow(at: IndexPath(row: 0, section: indexPath.section), animated: true)
    }
  }
  
}

extension UITableView {
  func deselectAll() {
    guard let indexPathsForSelectedRows = indexPathsForSelectedRows else {
      return
    }
    
    for indexPath in indexPathsForSelectedRows {
      if indexPath.row != 0 {
        deselectRow(at: indexPath, animated: false)
      }
    }
  }
}
