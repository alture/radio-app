//
//  RadioListTableViewController.swift
//  Radio
//
//  Created by Alisher on 8/4/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

enum RadioListType {
  case all
  case favorite
}

final class RadioListTableViewController: BaseTableViewController {
  
  
  // MARK: - Properties
  var presenter: RadioListPresentation?
  var type: RadioListType = .favorite
  @objc var radioPlayer = RadioPlayer.shared
  private var observations = [NSKeyValueObservation]()
  
  // MARK: - Private Properties
  private var radioList: [Radio] = []
  
  private var lastSelectedIndexPath: IndexPath?
  
  // MARK: - Search & Filter Properties
  
  private lazy var filterBarButtonItem: UIBarButtonItem = {
    let button = UIBarButtonItem(title: NSLocalizedString("Фильтр", comment: "Фильтр"), style: .plain, target: self, action: #selector(didTapFilterButton))
    button.tintColor =  #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
    return button
  }()
  private var filteredRadioList = [Radio]()
  private var isFiltering: Bool {
    return searchController.isActive && !isSearchBarEmpty
  }
  
  private var isSearchBarEmpty: Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  @IBOutlet var emptyView: UIView!
  @IBOutlet weak var emptyViewTitle: UILabel!
  @IBOutlet weak var emptyViewButton: UIButton! {
    didSet {
      emptyViewButton.layer.borderWidth = 1.0
      emptyViewButton.layer.borderColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
      emptyViewButton.layer.cornerRadius = 3.0
      emptyViewButton.clipsToBounds = true
    }
  }
  
  @IBAction func didTapFetch(_ sender: UIButton) {
    switch type {
    case .favorite:
      switchToDataTab()
    case .all:
      refresh()
    }
  }
  
  private var tabBar: RadioTabBarViewController {
    return super.parent!.parent as! RadioTabBarViewController
  }
  
  private lazy var searchController: UISearchController = UISearchController()
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setupTableView()
    setupObserver()
    
    switch type {
    case .favorite:
      emptyViewTitle.text = NSLocalizedString("Список моих станции пуст", comment: "Список моих станции пуст")
      emptyViewButton.setTitle(NSLocalizedString("Список моих станции пуст", comment: "Список моих станции пуст"), for: .normal)
    case .all:
      emptyViewTitle.text = NSLocalizedString("Cтанции еще нет,\nно мы работаем над этим", comment: "Cтанции еще нет,\nно мы работаем над этим")
      emptyViewButton.setTitle(NSLocalizedString("Cтанции еще нет,\nно мы работаем над этим", comment: "Cтанции еще нет,\nно мы работаем над этим"), for: .normal)
    }
    
    refresh()
  }
  
  // MARK: - Setup  
  private func setupObserver() {
    observations = [
      radioPlayer.observe(\.state,
                          options: .initial,
                          changeHandler: { (player, value) in
                            if player.state == .fail {
                              DispatchQueue.global().async {
                                self.handleError(nil,
                                                 .warning(text: NSLocalizedString("Не удается воспроизвести поток",
                                                          comment: "Не удается воспроизвести поток")))
                              }
                            }
                          }),
      radioPlayer.observe(\.currentRadio,
                          options: .initial,
                          changeHandler: { (player, value) in
                            self.setSelectedCell(from: player.currentRadio)
                          })
    ]
  }
  
  private func setSelectedCell(from radio: Radio?) {
    guard let radio = radio else {
      return
    }
    
    let currentRadioList = isFiltering
      ? filteredRadioList
      : radioList

    if let index = currentRadioList.firstIndex(of: radio) {
      let indexPath = IndexPath(row: index, section: 0)
      defer {
        lastSelectedIndexPath = indexPath
      }
      if let lastSelectedIndexPath = lastSelectedIndexPath {
        tableView.reloadRows(at: [indexPath, lastSelectedIndexPath], with: .none)
      } else {
        tableView.reloadRows(at: [indexPath], with: .none)
      }
      
    }
  }
  
  private func setupNavigationBar() {
    switch type {
    case .favorite: break
    case .all:
      let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                             target: self,
                                             action: #selector(didTapAddBarButton))
      addBarButtonItem.tintColor =  #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
      
      navigationItem.rightBarButtonItems = [filterBarButtonItem]
    }
    
    navigationItem.largeTitleDisplayMode = .always
    navigationController?.navigationBar.prefersLargeTitles = true
    setupSearchController()
  }
  
  private func setupSearchController() {
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = NSLocalizedString("Поиск", comment: "Поиск")
    searchController.searchBar.barTintColor = .white
    searchController.searchBar.backgroundImage = UIImage()
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  private func setupTableView() {
    tableView.backgroundView = emptyView
    tableView.allowsMultipleSelection = false
    tableView.allowsSelection = true
    tableView.backgroundView?.isHidden = true
    tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    tableView.refreshControl?.tintColor = #colorLiteral(red: 0.968627451, green: 0, blue: 0, alpha: 1)
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
  
  @objc private func didTapAddBarButton() {
    presenter?.addNewRadio()
  }
  
  @objc private func didTapFilterButton() {
    presenter?.didTapShowFilterView()
  }
  
  @objc private func refresh() {
    tableView.refreshControl?.beginRefreshing()
    switch type {
    case .all:
      presenter?.getRadioList(from: 0)
    default:
      presenter?.getFavoriteRadioList(from: 0)
    }
  }
  
  @IBAction func didTapAddButton(_ sender: UIButton) {
    presenter?.addNewRadio()
  }
  
  private func switchToDataTab() {
    Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToDataTabCont), userInfo: nil, repeats: false)
  }
  
  @objc private func switchToDataTabCont(){
    tabBarController!.selectedIndex = 1
  }
  
  private func didTapMoreButton(_ radio: Radio) {
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let addAction = UIAlertAction(title: NSLocalizedString("Добавить в Мои станции", comment: "Добавить в Мои станции"), style: .default) { (_) in
      self.presenter?.addToFavorite(radio.id)
      radio.isFavorite = true
      self.prepareResultView(with: .sucess(text: NSLocalizedString("Добавлено в Мои станции", comment: "Добавлено в Мои станции")))
    }
    
    let removeAction = UIAlertAction(title: NSLocalizedString("Убрать из Моих станции", comment: "Убрать из Моих станции"), style: .destructive) { (_) in
      self.presenter?.removeFromFavorite(radio.id)
      switch self.type {
      case .all: break
      case .favorite:
        if let index = self.radioList.firstIndex(of: radio) {
          let indexPath = IndexPath(row: index, section: 0)
          radio.isFavorite = false
          self.radioList.remove(at: index)
          self.tableView.deleteRows(at: [indexPath], with: .automatic)
          self.tableView.backgroundView?.isHidden = !self.radioList.isEmpty
        }
      }
    }
    
    let shareAction = UIAlertAction(title: NSLocalizedString("Поделится", comment: "Поделится"), style: .default) { (_) in
      // TODO: - Implement Share
    }
    
    alertController.addAction(shareAction)
    
    switch type {
    case .all:
      alertController.addAction(addAction)
    case .favorite:
      alertController.addAction(removeAction)
    }
    
    let cancelAction = UIAlertAction(title: NSLocalizedString("Отмена", comment: "Отмена"), style: .cancel)
    alertController.addAction(cancelAction)
    present(alertController, animated: true)
  }
  
  private func updateFilterLabel(filterCount: Int) {
    let barButtonTitle = "\(NSLocalizedString("Фильтр", comment: "Фильтр")) (\(filterCount))"
    filterBarButtonItem.title = filterCount > 0 ? barButtonTitle : NSLocalizedString("Фильтр", comment: "Фильтр")
  }
}

extension RadioListTableViewController: RadioListView {
  func updateViewFromModel(_ model: [Radio]) {
    radioList += model
    
    if model.count > 0 {
      tableView.reloadData()
    }
    refreshControl?.endRefreshing()
    tableView.backgroundView?.isHidden = !radioList.isEmpty
  }
}


// MARK: - TableViewDelegate
extension RadioListTableViewController {  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isFiltering ? filteredRadioList.count : radioList.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell") as! RadioListTableViewCell
    let currentRadioList = isFiltering ? filteredRadioList : radioList
    let radio = currentRadioList[indexPath.row]
    if
      let urlString = radio.logo,
      let url = URL(string: urlString) {
      cell.logoImage.loadImage(at: url)
    }
    cell.radio = radio
    cell.didTapMoreButton = { radio in
      self.didTapMoreButton(radio)
    }
    
    let lastIndex = radioList.count
    if indexPath.row == lastIndex - 5 {
      if !isFiltering {
        switch type {
        case .all:
          presenter?.getRadioList(from: lastIndex)
        case .favorite:
          presenter?.getFavoriteRadioList(from: lastIndex)
        }
      }
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let currentRadioList = isFiltering ? filteredRadioList : radioList
    let radio = currentRadioList[indexPath.row]
    if radioPlayer.currentRadio == radio && radioPlayer.state == .playing {
      radioPlayer.stopRadio()
    } else {
      radioPlayer.currentRadio = radio
      radioPlayer.playRadio()
    }
  }
}

extension RadioListTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchText = searchController.searchBar.text
    filterContentForSearchText(searchText!)
  }
}

extension RadioListTableViewController: RadioAddViewControllerDelegate {
  func radioAdded() {
    prepareResultView(with: .sucess(text: NSLocalizedString("Станция появится после модераций",
                                                            comment: "Станция появится после модераций")))
  }
}

extension RadioListTableViewController: EmptyViewDelegate {
  func didTapButton() {
    refresh()
  }
}

extension RadioListTableViewController: RadioFilterViewControllerDelegate {
  func didTapDone() {
    radioList = []
    tableView.refreshControl?.beginRefreshing()
    tableView.reloadData()
    switch type {
    case .all:
      presenter?.getRadioList(from: 0)
    default:
      presenter?.getFavoriteRadioList(from: 0)
    }
  }
}


