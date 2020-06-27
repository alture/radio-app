//
//  RadioListViewController.swift
//  Radio
//
//  Created by Alisher on 6/27/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

final class RadioListViewController: BaseViewController {
  
  // MARK: Properties
  
  var presenter: RadioListPresentation?
  var radioList: [Radio] = [] {
    didSet {
      tableView.reloadData()
//      for radio in radioList {
//        print(radio.name)
//        print(radio.url)
//      }
    }
  }
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    presenter?.getRadioList()
    setupNavigationBar()
    
    if let tabBar = super.parent?.parent as? RadioTabBarViewController {
      tabBar.prepareToPlay(with: "https://hls-02-europaplus.emgsound.ru/11/playlist.m3u8")
    }
  }
  
  private func setupNavigationBar() {
    title = "Мои станций"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.largeTitleDisplayMode = .always
  }
}

extension RadioListViewController: RadioListView {
  func updateViewFromModel(_ model: [Radio]) {
    radioList = model
  }
}

extension RadioListViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return radioList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell") as! RadioListTableViewCell
    cell.radio = radioList[indexPath.row]
    return cell
  }

}


