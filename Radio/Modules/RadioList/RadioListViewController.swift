//
//  RadioListViewController.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

enum RadioListType {
  case all
  case favorite
}

typealias FilteredValues = (genriesID: [Int], countriesID: [Int])

final class RadioListViewController: BaseViewController {
  
  // MARK: Properties
  
  var presenter: RadioListPresentation?
  var allRadioList: [Radio] = []
  var radioList: [Radio] = []
  var type: RadioListType = .favorite
  
  // MARK: - Search & Filter Properties
  var filteredRadioList: [Radio] = []
  var filterValues: FilteredValues?
  var isFiltering: Bool {
    guard let searchController = navigationItem.searchController else {
      return false
    }
    
    return searchController.isActive && !isSearchBarEmpty
  }
  
  var isSearchBarEmpty: Bool {
    return navigationItem.searchController?.searchBar.text?.isEmpty ?? true
  }
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.backgroundView = emptyView
    }
  }
  @IBOutlet weak var emptyView: UIView!
  private var tabBar: RadioTabBarViewController {
    return super.parent!.parent as! RadioTabBarViewController
  }
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    setupNavigationBar()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    setupView()
  }
  
  private func setupView() {
    switch type {
    case .favorite:
      presenter?.getFavoriteRadioList()
    case .all:
      presenter?.getRadioList()
    }
  }
  
  private func setupNavigationBar() {
    switch type {
    case .favorite:
      title = "Избранное"
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
    case .all:
      title = "Станций"
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Фильтр", style: .plain, target: self, action: #selector(didTapFilterButton))
      setupSearchController()
    }
    
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
  }
  
  private func setupSearchController() {
    let searchController = UISearchController()
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Поиск"
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  private func filterContentForSearchText(_ searchText: String) {
    filteredRadioList = radioList.filter { (radio: Radio) -> Bool in
      guard let radioName = radio.name else {
        return false
      }
    
      return radioName.lowercased().contains(searchText.lowercased())
    }
    
    tableView.reloadData()
  }
  
  private func updateRadioListWithFilter(_ filterValues: FilteredValues) {
    radioList = allRadioList.filter({ (radio) -> Bool in
      if let genreID = radio.genreID {
        print(filterValues.genriesID.isEmpty)
        if !filterValues.genriesID.isEmpty && !filterValues.genriesID.contains(genreID) {
          return false
        }
      }

      if let countryID = radio.countryID {
        if !filterValues.countriesID.isEmpty && !filterValues.countriesID.contains(countryID) {
          return false
        }
      }

      return true
    })
    
    tableView.reloadData()
  }
  
  @objc private func didTapAddButton() {
    
  }
  
  @objc private func didTapFilterButton() {
    presenter?.didTapShowFilterView()
  }
  
  private func didTapMoreButton(_ radio: Radio) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let addAction = UIAlertAction(title: "Добавить в избранное", style: .default) { (_) in
      if let id = radio.id {
        self.presenter?.addToFavorite(id)
      }
    }
    
    let removeAction = UIAlertAction(title: "Удалить", style: .destructive) { (_) in
      guard let id = radio.id else {
        return
      }
      
      self.presenter?.removeFromFavorite(id)
      switch self.type {
      case .all: break
      case .favorite:
        if let index = self.radioList.firstIndex(of: radio) {
          let indexPath = IndexPath(row: index, section: 0)
          self.radioList.remove(at: index)
          self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
      }
    }
    
    switch type {
    case .all:
      alertController.addAction(addAction)
    case .favorite:
      alertController.addAction(removeAction)
    }
    
    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
    alertController.addAction(cancelAction)
    present(alertController, animated: true)
  }
  
}

extension RadioListViewController: RadioListView {
  func updateViewFromModel(_ model: [Radio]) {
    allRadioList = model
    radioList = model
    tableView.reloadData()
  }
}

extension RadioListViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    tableView.backgroundView?.isHidden = !radioList.isEmpty
    tableView.isScrollEnabled = !radioList.isEmpty
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isFiltering ? filteredRadioList.count : radioList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell") as! RadioListTableViewCell
    let currentRadioList = isFiltering ? filteredRadioList : radioList
    let radio = currentRadioList[indexPath.row]
    cell.radio = radio
    cell.isPlaying = tabBar.currentRadio == radio
    cell.didTapMoreButton = { radio in
      self.didTapMoreButton(radio)
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let currentRadioList = isFiltering ? filteredRadioList : radioList
    let radio = currentRadioList[indexPath.row]
    if tabBar.currentRadio == radio && tabBar.isPlaying {
      tabBar.pauseStream()
    } else {
      tabBar.currentRadio = radio
      tabBar.prepareToPlay()
      tabBar.playStream()
    }
    
    tableView.reloadData()
  }

}

extension RadioListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchText = searchController.searchBar.text
    filterContentForSearchText(searchText!)
  }
}

extension RadioListViewController: RadioFilterViewControllerDelegate {
  func didTapShowWithFilter(filter values: FilteredValues) {
    filterValues = values
    var filterCount = 0
    if !values.countriesID.isEmpty { filterCount += 1 }
    if !values.genriesID.isEmpty { filterCount += 1 }
    
    let barButtonTitle = "Фильтр (\(filterCount))"
    navigationItem.rightBarButtonItem?.title = filterCount > 0 ? barButtonTitle : "Фильтр"
    updateRadioListWithFilter(values)
  }
}


