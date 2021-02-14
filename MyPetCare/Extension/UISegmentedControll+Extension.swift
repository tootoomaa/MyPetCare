//
//  UISegmentedControll+Extension.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/05.
//

import Foundation
import UIKit

extension UISegmentedControl {
    
    func removeBorder() {
        
        let backgroundImage = UIImage.getColoredRectImageWith(color: UIColor.white.cgColor, andSize: self.bounds.size)
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)

        let deviderImage = UIImage.getColoredRectImageWith(color: UIColor.white.cgColor, andSize: CGSize(width: 1.0, height: self.bounds.size.height))
        
        self.setDividerImage(deviderImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        
        self.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.systemGray5,
             NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)], for: .normal)
//
        self.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.black,
             NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)], for: .selected)
    }
}

