//
//  RadioListTableViewController.swift
//  Radio
//
//  Created by Alisher on 8/4/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import SDWebImage

enum RadioListType {
  case all
  case favorite
}

enum RadioListState {
  case loaded
  case paginted
  case filtered
}

final class RadioListTableViewController: BaseTableViewController {

  // MARK: - Properties
  var presenter: RadioListPresentation?
  var type: RadioListType = .favorite
  private var state: RadioListState = .loaded
  @objc var radioPlayer = RadioPlayer.shared
  private var observations = [NSKeyValueObservation]()
  
  // MARK: - Private Properties
  private var radioList: [Radio] = []
  private var lastSelectedIndexPath: IndexPath?
  
  // MARK: - Search & Filter Properties
  
  private lazy var filterBarButtonItem: UIBarButtonItem = {
    let badgeBarButton = BadgeBarButton(frame: CGRect(x: 0, y: 0, width: 30, height: 26))
    badgeBarButton.setBackgroundImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
    badgeBarButton.imageView?.contentMode = .scaleAspectFill
    badgeBarButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
    let barButtonItem = UIBarButtonItem(customView: badgeBarButton)
    barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 26.0).isActive = true
    barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
    return barButtonItem
  }()
  
  private var filteredRadioList = [Radio]()
  private var isFiltering: Bool {
    return searchController.isActive && (!isSearchBarEmpty  || type == .all)
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
      emptyViewButton.setTitle(NSLocalizedString("Выбрать и добавить", comment: "Список моих станции пуст"), for: .normal)
    case .all:
      emptyViewTitle.text = NSLocalizedString("Cтанции еще нет,\nно мы работаем над этим", comment: "Cтанции еще нет,\nно мы работаем над этим")
      emptyViewButton.setTitle(NSLocalizedString("Обновить", comment: "Cтанции еще нет,\nно мы работаем над этим"), for: .normal)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateFilterLabel()
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
                          changeHandler: { [weak self] (player, value) in
                            guard let `self` = self else { return }
                            
                            self.tableView.reloadData()
//                            self.setSelectedCell(from: player.currentRadio)
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
    
    switch type {
    case .all:
      presenter?.didTapSearchRadio(from: searchText)
      tableView.reloadData()
    case .favorite:
      filteredRadioList = radioList.filter { (radio: Radio) -> Bool in
        guard let radioName = radio.name else {
          return false
        }
        
        return radioName.lowercased().contains(searchText.lowercased())
      }
      
      tableView.reloadData()
    }
  
  }
  
  private func updateFilterTitle() {
    let filterCount = UserDefaults.standard.integer(forKey: "Filter")
    if let title = filterBarButtonItem.title, filterCount > 0 {
      filterBarButtonItem.title = "\(title) \(filterCount)"
    }
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
      presenter?.getRadioList(from: 0, to: radioList.count)
    default:
      presenter?.getFavoriteRadioList(from: 0, to: radioList.count)
    }
  }
  
  @IBAction func didTapAddButton(_ sender: UIButton) {
    presenter?.addNewRadio()
  }
  
  private func switchToDataTab() {
    Timer.scheduledTimer(timeInterval: 0.2,
                         target: self,
                         selector: #selector(switchToDataTabCont),
                         userInfo: nil,
                         repeats: false)
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
      
      var defaultText = NSLocalizedString("Слушай бесплатно - ", comment: "Слушай бесплатно")
      if let radioName = radio.name {
        defaultText += radioName + " "
      }
      
      // MARK: - Fix
      defaultText += "в приложений " + "\(UIApplication.appName!) - https://apps.apple.com/app/id1524028705)"
      let activityController: UIActivityViewController
      if
        let radioImageString = radio.logo,
        let radioImageURL = URL(string: radioImageString),
        let data = try? Data(contentsOf: radioImageURL),
        let imageToShare = UIImage(data: data) {
          activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
      } else {
          activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
      }
      
      self.present(activityController, animated: true, completion: nil)
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
  
  private func updateFilterLabel() {
    let filterCount = UserDefaults.standard.integer(forKey: "Filter")
    if let badgeBarButton = filterBarButtonItem.customView as? BadgeBarButton {
      badgeBarButton.setBadgeNumber(filterCount)
    }
  }
}

extension RadioListTableViewController: RadioListView {
  func updateViewFromModel(_ model: [Radio]) {
    switch state {
    case .loaded:
      radioList = model
    case .paginted:
      radioList += model
      if radioPlayer.type == .all, radioPlayer.currentRadio != nil {
        radioPlayer.update(radioList)
      }
    case .filtered:
      radioList = model
      lastSelectedIndexPath = nil
    }
    
    state = .loaded
    tableView.reloadData()
    refreshControl?.endRefreshing()
    tableView.backgroundView?.isHidden = !radioList.isEmpty
  }
  
  func updateViewFromFetchedList(_ radioList: [Radio]) {
    filteredRadioList = radioList
    tableView.reloadData()
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
      cell.logoImage.sd_setImage(with: url, placeholderImage: UIImage(named: "default-2"))
    }
    cell.radio = radio
    cell.didTapMoreButton = { radio in
      self.didTapMoreButton(radio)
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let currentRadioList = isFiltering ? filteredRadioList : radioList
    radioPlayer.load(currentRadioList[indexPath.row], from: currentRadioList, with: type)
  }
  
  override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let currentOffset = scrollView.contentOffset.y
    let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
    if maximumOffset - currentOffset <= 450.0 {
      if type == .all, state == .loaded {
        state = .paginted
        presenter?.getRadioList(from: radioList.count, to: 50)
      }
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
    tableView.reloadData()
    state = .filtered
    updateFilterLabel()
    tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentOffset.y - (tableView.refreshControl!.frame.size.height)), animated: true)
    tableView.refreshControl?.beginRefreshing()
    switch type {
    case .all:
      presenter?.getRadioList(from: 0, to: 50)
    default:
      presenter?.getRadioList(from: 0, to: 50)
    }
  }
}

extension UIRefreshControl {
  func beginRefreshingManually() {
    if let scrollView = superview as? UIScrollView {
      scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: true)
      beginRefreshing()
    }
  }
}

