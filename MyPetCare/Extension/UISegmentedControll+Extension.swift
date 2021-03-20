//
//  UISegmentedControll+Extension.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/05.
//

import Foundation
import UIKit

extension UISegmentedControl {
    
    func removeBorder(nomal: UIColor, selected: UIColor, centerBoarderWidth: CGFloat) {
        
        let nomalBackgroundImg = UIImage.getColoredRectImageWith(color: nomal.cgColor, andSize: self.bounds.size)
        let selectedBackGroundImg = UIImage.getColoredRectImageWith(color: selected.cgColor, andSize: self.bounds.size)
        
        self.setBackgroundImage(nomalBackgroundImg, for: .normal, barMetrics: .default)
        self.setBackgroundImage(selectedBackGroundImg, for: .selected, barMetrics: .default)
//        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)

        let deviderImage = UIImage.getColoredRectImageWith(color: UIColor.black.cgColor, andSize: CGSize(width: centerBoarderWidth, height: self.bounds.size.height))
        
        self.setDividerImage(deviderImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        
        self.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.systemGray5,
             NSAttributedString.Key.font: UIFont(name: "Cafe24Syongsyong", size: 17)!], for: .normal)
        
        self.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.black,
             NSAttributedString.Key.font: UIFont(name: "Cafe24Syongsyong", size: 17)!], for: .selected)
    }
}

