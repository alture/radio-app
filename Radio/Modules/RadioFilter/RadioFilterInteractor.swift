//
//  RadioFilterInteractor.swift
//  Radio
//
//  Created by Alisher on 6/30/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

final class RadioFilterInteractor {
  
  // MARK: Properties
  
  weak var output: RadioFilterInteractorOutput?
}

extension RadioFilterInteractor: RadioFilterUseCase {
  func fetchData() {
    var genriesData = [Genre]()
    var countryData = [Country]()
    GenreAPI.getGenries { (response, error) in
      if let error = error {
        self.output?.handleError(error)
        return
      }
      
      if let genries = response as? [Genre] {
        genriesData = genries
      }
      
      CountryAPI.getCountries { (response, error) in
        if let error = error {
          self.output?.handleError(error)
          return
        }
        
        if let country = response as? [Country]  {
          countryData = country
        }
        
        self.output?.fetchedDate(genriesData, countryData)
      }
    }
  }
}
