//
//  TestAPIViewController.swift
//  Radio
//
//  Created by Alisher on 6/25/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit
import Alamofire

class TestAPIViewController: BaseViewController {
  
  let baseURL = "http://79.137.222.49/api/v1"
  let headers: HTTPHeaders = [
      "X-RADIO-CLIENT-ID": "adcb64ee-b6e5-11ea-b3de-0242ac130004",
  ]
  
  @IBOutlet private var cardButtons: [UIButton]!
  @IBAction private func touchButton(_ sender: UIButton) {
    if let index = cardButtons.firstIndex(of: sender) {
        switch index {
        case 0: break
        case 1: getCountry()
        case 2: getGenre()
        case 3: getRadio()
        case 4: getMyRadio()
        case 5: like(with: 4)
        case 6: dislike(with: 4)
        case 7: createRadio()
        default: break
        }
      } else {
          print("Choosen card was not in CardButtons")
      }
  }
  
  private func getCountry() {
    CountryAPI.getCountries { (response, error) in
      if error != nil {
        self.showErrorAlert(with: error?.localizedDescription ?? "Ошибка")
        return
      }
      
//      if let countries = Country.getArray(from: response ?? []) {
//        for country in countries {
////          print(country.name)
//        }
//      }
  
    }
  }
  
  private func getGenre() {
    GenreAPI.getGenries { (response, error) in
      if error != nil {
        self.showErrorAlert(with: error?.localizedDescription ?? "Ошибка")
        return
      }
      
//      if let genries = Genre.getArray(from: response ?? []) {
//        for genre in genries {
////          print(genre.name)
//        }
//      }
    }
  }
  
  private func getRadio() {
    RadioAPI.getRadios { (response, error) in
      if error != nil {
        self.showErrorAlert(with: error?.localizedDescription ?? "Ошибка")
        return
      }
      
//      if let radios = Radio.getArray(from: response ?? []) {
//        for radio in radios {
////          print(radio.name)
////          print(radio.enabled)
////          print(radio.id)
//        }
//      }
    }
  }
  
  private func getMyRadio() {
    RadioAPI.getFavoriteRadios { (response, error) in
      if error != nil {
        self.showErrorAlert(with: error?.localizedDescription ?? "Ошибка")
        return
      }
      
//      if let radios = Radio.getArray(from: response ?? []) {
//        for radio in radios {
////          print(radio.name)
////          print(radio.enabled)
////          print(radio.id)
//        }
//      }
    }
  }
  
  private func like(with id: Int) {
    RadioAPI.addToFavorite(8) { (error) in
      if error != nil {
        self.showErrorAlert(with: error?.localizedDescription ?? "Ошибка")
        return
      }
    }
  }
  
  private func dislike(with id: Int) {
    RadioAPI.removeFromFavorite(8) { (error) in
      if error != nil {
        self.showErrorAlert(with: error?.localizedDescription ?? "Ошибка")
        return
      }
    }
  }
  
  private func createRadio() {
    RadioAPI.createRadio(with: "Empire", url: "http://test.radio.com/stream/empire.m3u", logoURL: "logo") { (error) in
      if error != nil {
        self.showErrorAlert(with: error?.localizedDescription ?? "Ошибка")
        return
      }
    }
  }
  
  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
  }
  


  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destination.
      // Pass the selected object to the new view controller.
  }
  */

}
