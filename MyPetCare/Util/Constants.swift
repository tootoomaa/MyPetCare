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
    
    // Locale
    static let currentLocale = Locale(identifier: "ko_KR")
    
    // UI
    static var viewHeigth = UIScreen.main.bounds.height
    static var viewWidth = UIScreen.main.bounds.width
    
    static var mainColor = UIColor.lightGreen
    
    static var mainViewPetPlusButtonUUID = "itisButtonUUIDforAddPet"
    
}
