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
  func didTapAppendFilters(_ genres: [Genre], _ countries: [Country])
}

final class RadioFilterViewController: BaseViewController {
  
  // MARK: Properties
  
  var delegate: RadioFilterViewControllerDelegate?
  
  var presenter: RadioFilterPresentation?
  
  private lazy var realm: Realm = {
    let rlm: Realm
    do {
      rlm = try Realm()
    } catch let error {
      fatalError(error.localizedDescription)
    }
    return rlm
  }()
  
  private var genries: [Genre] {
    return Array(realm.objects(Genre.self))
  }
  private var countries: [Country] {
    return Array(realm.objects(Country.self))
  }
  
  var selectedGenries: [Genre] = []
  var selectedCountries: [Country] = []
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
  }
  
  private func setupNavigationBar() {
    let barButtonItem = UIBarButtonItem(
      title: NSLocalizedString("Готово", comment: "Готово"),
      style: .done,
      target: self,
      action: #selector(didTapDoneButton))
    barButtonItem.tintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
    navigationItem.rightBarButtonItem = barButtonItem
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
    do {
      try realm.write {
        if !realm.objects(Genre.self).isEmpty {
          realm.delete(genries)
        }
        
        if !realm.objects(Country.self).isEmpty {
          realm.delete(countries)
        }
        
        realm.add(genre)
        realm.add(country)
      }
    } catch let error {
      fatalError(error.localizedDescription)
    }
    tableView.reloadData()
    return
  }
}

extension RadioFilterViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return NSLocalizedString("Жанр", comment: "Жанр")
    case 1: return NSLocalizedString("Страна", comment: "Страна")
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
    let cell = RadioFilterCell(style: .subtitle, reuseIdentifier: "DataCell")
    cell.selectionStyle = .none
    cell.tintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
    cell.detailTextLabel?.textColor = .darkGray
    if indexPath.row == 0 {
      cell.textLabel?.text = indexPath.section == 0
        ? NSLocalizedString("Все жанры", comment: "Все жанры")
        : NSLocalizedString("Все страны", comment: "Все страны")
      if indexPath.section == 0 {
        if selectedGenries.isEmpty {
          tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
      } else {
        if selectedCountries.isEmpty {
          tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
      }
    } else {
      let currentTitle: String?
      let numberStation: Int
      
      if indexPath.section == 0 {
        let currentGenre = genries[indexPath.row-1]
        currentTitle = currentGenre.name
        numberStation = currentGenre.stations
        
        if selectedGenries.contains(currentGenre) {
          tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
      } else {
        let currentCountry = countries[indexPath.row-1]
        currentTitle = currentCountry.name
        numberStation = currentCountry.stations
        
        if selectedCountries.contains(currentCountry) {
          tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
      }
      
      cell.textLabel?.text = currentTitle
      cell.detailTextLabel?.text = "\(numberStation)"
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row != 0 && (selectedGenries.count > 5 || selectedCountries.count > 5) {
      prepareResultView(with: .warning(text: NSLocalizedString("Возможно выбрать максимум 5!", comment: "Предупреждение в окне фильтра")))
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
