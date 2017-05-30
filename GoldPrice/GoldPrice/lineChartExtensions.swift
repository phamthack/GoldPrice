//
//  lineChartExtensions.swift
//  GoldPrice
//
//  Created by Phạm Thanh Hùng on 5/30/17.
//  Copyright © 2017 Phạm Thanh Hùng. All rights reserved.
//

import UIKit

extension String {
    func size(withSystemFontSize pointSize: CGFloat) -> CGSize {
        return (self as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: pointSize)])
    }
}

extension CGPoint {
    func adding(x: CGFloat) -> CGPoint { return CGPoint(x: self.x + x, y: self.y) }
    func adding(y: CGFloat) -> CGPoint { return CGPoint(x: self.x, y: self.y + y) }
}
