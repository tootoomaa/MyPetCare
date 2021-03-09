//
//  Constants.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/05.
//

import Foundation
import UIKit

class Constants {
    
    // System
    class ScreenHeight {
        static let iphoneSE1Gen: CGFloat = 568.0   // se1 , 5s
        static let iphoneSE2Gen: CGFloat = 667.0   // se2, 6, 7, 8
        static let maxDevice: CGFloat = 900        // max
    }
    
    static let DB_VERSION: UInt64 = 8
    
    // Measure View
    static let maxMeasureCount: Int = 60
    
    // Locale
    static let currentLocale = Locale(identifier: "ko_KR")
    
    // UI
    static let widthbase: CGFloat = 375
    static let heigthbase: CGFloat = 700
    
    static let viewHeigth = UIScreen.main.bounds.height
    static let viewWidth = UIScreen.main.bounds.width
    
    static let heightRatio = UIScreen.main.bounds.height / Constants.heigthbase
    static let widthRatio = UIScreen.main.bounds.width / Constants.widthbase
    
    static let emptyImage = UIImage(systemName: "questionmark.circle")?
                                    .withRenderingMode(.alwaysOriginal)
                                    .withTintColor(.black)
                                    .pngData()!
    
    // Color
    static var mainColor = UIColor.lightGreen
    
    static var mainViewPetPlusButtonUUID = "itisButtonUUIDforAddPet"
    
    
    // Main View Controller
    enum MainFrameTableViewItem: CaseIterable {
        case petProfile
        case service
    }
    
    // Statictic
    enum duration: Int, CaseIterable {
        case weak = 0
        case month = 1
    }
}
