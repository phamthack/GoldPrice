//
//  StringExtensions.swift
//  GoldPrice
//
//  Created by Phạm Thanh Hùng on 6/2/17.
//  Copyright © 2017 Phạm Thanh Hùng. All rights reserved.
//
import UIKit
import Foundation

extension String {
    func size(withSystemFontSize pointSize: CGFloat) -> CGSize {
        return (self as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: pointSize)])
    }
}
