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


class RadioListTableViewController: BaseTableViewController {
  
  // MARK: - Properties
  var presenter: RadioListPresentation?
  var type: RadioListType = .favorite
  @objc var radioPlayer = RadioPlayer.shared
  private var observations = [NSKeyValueObservation]()
  
  
  // MARK: - Private Properties
  private var allRadioList: [Radio] = []
  private var radioList: [Radio] = []
  
  private var selectedGenres: [Genre] = []
  private var selectedCountries: [Country] = []
    
  // MARK: - Search & Filter Properties
  
  private lazy var filterBarButtonItem: UIBarButtonItem = {
    let button = UIBarButtonItem(title: "Фильтр", style: .plain, target: self, action: #selector(didTapFilterButton))
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
      emptyViewTitle.text = "Список моих станции пуст"
      emptyViewButton.setTitle("Добавить", for: .normal)
    case .all:
      emptyViewTitle.text = "Cтанции еще нет,\nно мы работаем над этим"
      emptyViewButton.setTitle("Обновить", for: .normal)
    }
    
    tableView.refreshControl?.beginRefreshing()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    refresh()
  }
      
  // MARK: - Setup
  private func setupObserver() {
    observations = [
      radioPlayer.observe(\.currentRadio,
                                    options: .initial,
                                   changeHandler: { (radio, value) in
                                    self.tableView.reloadData()
      }),
      radioPlayer.observe(\.state,
                           options: .initial,
                           changeHandler: { (player, value) in
                            if player.state == .fail {
                              self.showErrorAlert(with: "Не удается воспроизвести поток")
                            }
      })]
  }
  
  private func setupNavigationBar() {
    switch type {
    case .favorite:
      title = "Мои станции"
    case .all:
      title = "Станции"
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
    searchController.searchBar.placeholder = "Поиск"
    searchController.searchBar.barTintColor = .white
    searchController.searchBar.backgroundImage = UIImage()
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  private func setupTableView() {
    tableView.backgroundView = emptyView
    tableView.backgroundView?.isHidden = true
    tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    
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
    presenter?.didTapShowFilterView(with: selectedGenres, selectedCountries)
  }
  
  @objc private func refresh() {
    switch type {
    case .all:
      presenter?.getRadioList()
    default:
      presenter?.getFavoriteRadioList()
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
    let addAction = UIAlertAction(title: "Добавить в Мои станции", style: .default) { (_) in
      self.presenter?.addToFavorite(radio.id)
      self.prepareResultView(with: .sucess(text: "Добавлено в Мои станции"))
    }
    
    let removeAction = UIAlertAction(title: "Убрать из Моих станции", style: .destructive) { (_) in
      self.presenter?.removeFromFavorite(radio.id)
      switch self.type {
      case .all: break
      case .favorite:
        if let index = self.radioList.firstIndex(of: radio) {
          let indexPath = IndexPath(row: index, section: 0)
          self.radioList.remove(at: index)
          self.tableView.deleteRows(at: [indexPath], with: .automatic)
          self.tableView.backgroundView?.isHidden = !self.radioList.isEmpty
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
  
  private func loadFilter(_ genres: [Genre], _ countries: [Country], animated: Bool) {
    var filterCount = 0
    
    if !genres.isEmpty { filterCount += 1 }
    if !countries.isEmpty { filterCount += 1 }
    updateFilterLabel(filterCount: filterCount)
    if animated {
      tableView.beginUpdates()
    }
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
    if animated {
      tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
      tableView.endUpdates()
    }
    
  }
  
  private func updateFilterLabel(filterCount: Int) {
    let barButtonTitle = "Фильтр (\(filterCount))"
    filterBarButtonItem.title = filterCount > 0 ? barButtonTitle : "Фильтр"
  }
  
}

extension RadioListTableViewController: RadioListView {
  func updateViewFromModel(_ model: [Radio]) {
    allRadioList = model
    radioList = model
    loadFilter(selectedGenres, selectedCountries, animated: false)
    tableView.reloadData()
    refreshControl?.endRefreshing()

    tableView.backgroundView?.isHidden = !model.isEmpty
  }
}

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
    cell.radio = radio
    cell.isPlaying = radioPlayer.currentRadio == radio
    cell.didTapMoreButton = { radio in
      self.didTapMoreButton(radio)
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let currentRadioList = isFiltering ? filteredRadioList : radioList
    let radio = currentRadioList[indexPath.row]
    radioPlayer.currentRadio = radio
    radioPlayer.playRadio()
  }
}

extension RadioListTableViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchText = searchController.searchBar.text
    filterContentForSearchText(searchText!)
  }
}

extension RadioListTableViewController: RadioFilterViewControllerDelegate {
  func didTapAppendFilters(_ genres: [Genre], _ countries: [Country]) {
    selectedGenres = genres
    selectedCountries = countries
    loadFilter(genres, countries, animated: true)
  }
}

extension RadioListTableViewController: RadioAddViewControllerDelegate {
  func radioAdded() {
    prepareResultView(with: .sucess(text: "Станция появится после модераций"))
  }
}

extension RadioListTableViewController: EmptyViewDelegate {
  func didTapButton() {
    refresh()
  }
}


