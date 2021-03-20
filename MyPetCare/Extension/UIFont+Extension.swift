//
//  UIFont+Extension.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/20.
//

import Foundation
import UIKit

extension UIFont {
    
    static func dynamicFont(name: String, size: CGFloat) -> UIFont {
        
        var dynamicFontSize: CGFloat = size
        
        if Constants.viewHeigth == Constants.ScreenHeight.iphoneSE1Gen ||
            Constants.viewHeigth > Constants.ScreenHeight.maxDevice {
            dynamicFontSize = size*Constants.heightRatio
        }
        
        guard let font = UIFont(name: name, size: dynamicFontSize) else {
            return .systemFont(ofSize: dynamicFontSize)
        }
        
        return font
    }
    
    static func dynamicSystemFont(size: CGFloat, weight: Weight = .regular) -> UIFont {
        
        var dynamicFontSize = size
        
        if Constants.viewHeigth == Constants.ScreenHeight.iphoneSE1Gen ||
            Constants.viewHeigth > Constants.ScreenHeight.maxDevice {
            dynamicFontSize = size*Constants.widthRatio
        }

        return .systemFont(ofSize: dynamicFontSize, weight: weight)
    }
}
