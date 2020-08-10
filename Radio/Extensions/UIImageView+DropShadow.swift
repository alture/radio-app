//
//  UIImageView+DropShadow.swift
//  Radio
//
//  Created by Alisher on 8/10/20.
//  Copyright © 2020 Alisher. All rights reserved.
//

import UIKit

extension UIImageView {
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
