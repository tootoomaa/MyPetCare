//
//  Constants.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/05.
//

import Foundation
import UIKit

class Constants {
    
    enum MainFrameTableViewItem: CaseIterable {
        case petProfile
        case service
    }
    
    // Measure View
    static let maxMeasureCount: Int = 60
    
    // Locale
    static let currentLocale = Locale(identifier: "ko_KR")
    
    // UI
    static var widthbase: CGFloat = 375
    static var heigthbase: CGFloat = 700
    
    static var viewHeigth = UIScreen.main.bounds.height
    static var viewWidth = UIScreen.main.bounds.width
    
    static var heightRatio = UIScreen.main.bounds.height / Constants.heigthbase
    static var widthRatio = UIScreen.main.bounds.width / Constants.widthbase
    
    // Color
    static var mainColor = UIColor.lightGreen
    
    static var mainViewPetPlusButtonUUID = "itisButtonUUIDforAddPet"
    
    
    class ScreenHeight {
        
        static let iphoneSE1Gen: CGFloat = 568.0   // se1 , 5s
        static let iphoneSE2Gen: CGFloat = 667.0   // se2, 6, 7, 8
        static let maxDevice: CGFloat = 900        // max
    }
}
