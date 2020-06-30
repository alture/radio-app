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

final class RadioListViewController: BaseViewController {
  
  // MARK: Properties
  
  var presenter: RadioListPresentation?
  var radioList: [Radio] = []
  
  var selectedIndexPath: IndexPath?
  var type: RadioListType = .favorite
  
  // MARK: - Search & Filter Properties
  var filteredRadioList: [Radio] = []
  var filterValues: (genre: String?, country: String?) = (nil, nil)
  var isFiltering: Bool {
    return navigationItem.searchController?.isActive ?? false && !isSearchBarEmpty
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
  
  func filterContentForSearchText(_ searchText: String) {
    filteredRadioList = radioList.filter { (radio: Radio) -> Bool in
      guard let radioName = radio.name else {
        return false
      }
      
      return radioName.lowercased().contains(searchText.lowercased())
    }
    
    tableView.reloadData()
  }
  
  @objc private func didTapAddButton() {
    
  }
  
  @objc private func didTapFilterButton() {
    presenter?.didTapShowFilterView()
  }
}

extension RadioListViewController: RadioListView {
  func updateViewFromModel(_ model: [Radio]) {
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
    if isFiltering {
      return filteredRadioList.count
    } else {
      return radioList.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell") as! RadioListTableViewCell
    if isFiltering {
      cell.radio = filteredRadioList[indexPath.row]
    } else {
      cell.radio = radioList[indexPath.row]
    }
    
    cell.isPlaying = selectedIndexPath == indexPath
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if selectedIndexPath == indexPath && tabBar.isPlaying {
      tabBar.pauseStream()
    } else {
      tabBar.prepareToPlay(with: radioList[indexPath.row])
      tabBar.playStream()
    }
    
    selectedIndexPath = indexPath
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView,
                 trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard type == .favorite else {
      return nil
    }
    
    let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (action, sourceView, completionHandler) in
      if let id = self.radioList[indexPath.row].id  {
        self.presenter?.removeFromFavorite(id)
        self.radioList.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        completionHandler(true)
      } else {
        completionHandler(false)
      }
    }
    
    deleteAction.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    deleteAction.image = UIImage(systemName: "trash.fill")
    
    let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
    return swipeConfiguration
  }
  
  func tableView(_ tableView: UITableView,
                 leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard type == .all else {
      return nil
    }
    
    let addAction = UIContextualAction(style: .normal, title: "Добавить") { (action, sourceView, completionHandler) in
      if let id = self.radioList[indexPath.row].id  {
        self.presenter?.addToFavorite(id)
        let radioRate = self.radioList[indexPath.row].rate ?? 0
        self.radioList[indexPath.row].rate = radioRate == 0 ? 1 : 0
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        completionHandler(true)
      } else {
        completionHandler(false)
      }
    }
    
    let checkInIcon = (self.radioList[indexPath.row].rate ?? 0) == 1 ? "arrow.uturn.left" : "checkmark"
    addAction.backgroundColor = UIColor(red: 38.0/255.0, green: 162.0/255.0, blue: 78.0/255.0, alpha: 1.0)
    addAction.image = UIImage(systemName: checkInIcon)
    
    let swipeConfiguration = UISwipeActionsConfiguration(actions: [addAction])
    return swipeConfiguration
  }

}

extension RadioListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text ?? "")
  }
}


