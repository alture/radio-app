//
//  RadioFilterCellTableViewCell.swift
//  Radio
//
//  Created by Alisher on 6/30/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

class RadioFilterCell: UITableViewCell {
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    accessoryType = selected ? .checkmark : .none
  }  
}
