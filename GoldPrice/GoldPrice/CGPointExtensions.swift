//
//  CGPointExtensions.swift
//  GoldPrice
//
//  Created by Phạm Thanh Hùng on 6/2/17.
//  Copyright © 2017 Phạm Thanh Hùng. All rights reserved.
//
import UIKit
import Foundation

extension CGPoint {
    func adding(x: CGFloat) -> CGPoint { return CGPoint(x: self.x + x, y: self.y) }
    func adding(y: CGFloat) -> CGPoint { return CGPoint(x: self.x, y: self.y + y) }
}
