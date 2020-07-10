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
  var type: RadioListType = .favorite
  private var allRadioList: [Radio] = []
  private var radioList: [Radio] = []
  
  // MARK: - Search & Filter Properties
  private var filteredRadioList: [Radio] = []
  private var filterValues: FilteredValues?
  private var isFiltering: Bool {
    return searchController.isActive && !isSearchBarEmpty
  }
  
  private var isSearchBarEmpty: Bool {
    return searchController.searchBar.text?.isEmpty ?? true
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
  
  private lazy var searchController = UISearchController(searchResultsController: nil)
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
    
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
    navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
  }
  
  private func setupSearchController() {
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
  
//  private func updateRadioListWithFilter(_ filterValues: FilteredValues) {
//    radioList = allRadioList.filter({ (radio) -> Bool in
//      if let genres = radio.genres, !genres.isEmpty {
//        let listSet = NSSet(array: genres)
//        let findListSet = NSSet(array: )
//
//        let allElemtsEqual = findListSet.isSubsetOfSet(otherSet: listSet)
//
//      }
//
//      if let countryID = radio.countryID {
//        if !filterValues.countriesID.isEmpty && !filterValues.countriesID.contains(countryID) {
//          return false
//        }
//      }
//
//      return true
//    })
//
//    tableView.reloadData()
//  }
  
  @objc private func didTapAddButton() {
    presenter?.addNewRadio()
  }
  
  @objc private func didTapFilterButton() {
    presenter?.didTapShowFilterView()
  }
  
  private func didTapMoreButton(_ radio: Radio) {
    guard let id = radio.id else {
      return
    }
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let addAction = UIAlertAction(title: "Добавить в избранное", style: .default) { (_) in
      self.presenter?.addToFavorite(id)
      self.showResultView(with: .sucess(text: "\(radio.name ?? "Cтанция") - теперь в избранном!"))
    }
    
    let removeAction = UIAlertAction(title: "Удалить", style: .destructive) { (_) in
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
    
    let shareAction = UIAlertAction(title: "Поделится", style: .default) { (_) in
      // TODO: - Implement Share
    }
    
    alertController.addAction(shareAction)
    
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
  func didTapAppendFilters(_ genres: [Genre], _ countries: [Country]) {
    tableView.beginUpdates()
    radioList = allRadioList.filter({ (radio) -> Bool in
      if let radioGenres = radio.genres, !genres.isEmpty {
        for genre in radioGenres {
          if !genres.contains(genre) {
            return false
          }
        }
      }

      guard let country = radio.country else {
        return true
      }
      
      return countries.isEmpty ? true : countries.contains(country)
    })
    tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    tableView.endUpdates()
  }
  
  func didTapShowWithFilter(filter values: FilteredValues) {
    filterValues = values
    var filterCount = 0
    if !values.countriesID.isEmpty { filterCount += 1 }
    if !values.genriesID.isEmpty { filterCount += 1 }
    
    let barButtonTitle = "Фильтр (\(filterCount))"
    navigationItem.rightBarButtonItem?.title = filterCount > 0 ? barButtonTitle : "Фильтр"
  }
}

extension RadioListViewController: RadioAddViewControllerDelegate {
  func radioAdded() {
    showResultView(with: .sucess(text: "Станция в эфире!"))
  }
}
