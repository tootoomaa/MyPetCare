//
//  UINavigation+Extension.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/07.
//

import Foundation
import UIKit

extension UINavigationController {
    
    func configureNavigation(_ color: UIColor, largeTitle: Bool) {
        
        let titleAttrStringOption = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "Cafe24Syongsyong", size: 25)!
        ]
        
        _ = self.navigationBar.then {
            
            $0.prefersLargeTitles = largeTitle
            $0.isTranslucent = largeTitle
            
            $0.largeTitleTextAttributes = titleAttrStringOption
            $0.titleTextAttributes = titleAttrStringOption
            
            
            $0.shadowImage = UIImage()
            $0.topItem?.title = ""
            $0.tintColor = .black
            $0.barTintColor = color
            $0.shadowImage = UIImage()
        }
    }
}
