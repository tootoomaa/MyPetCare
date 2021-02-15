//
//  UIColor+Extension.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/05.
//

import Foundation
import UIKit

extension UIColor {
    
    static var extraLightPink: UIColor {
        return UIColor(rgb: 0xf6ecf0)
    }
    
    static var extraGray: UIColor {
        return UIColor(rgb: 0xe8eae6)
    }
    
    static var lightGreen: UIColor {
        return UIColor(rgb: 0xcfdac8)
    }
    
    static var cViolet: UIColor {
        return UIColor(rgb: 0xff7b54)
    }
    
    static var deepGreen: UIColor {
        return UIColor(rgb: 0x839b97)
    }
    
    static var serviceColor: UIColor {
        return UIColor(rgb: 0x75cfb8)
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
