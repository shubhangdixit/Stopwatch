//
//  UILabelExtension.swift
//  StopWatch
//
//  Created by Shubhang Dixit on 20/10/19.
//  Copyright © 2019 Shubhang. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func setFixedWidthFont(forWeight weight: UIFont.Weight) {
        self.font = UIFont.monospacedDigitSystemFont(ofSize: self.font.pointSize, weight: weight)
    }
}
