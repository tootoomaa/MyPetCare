//
//  UINavigation+Extension.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/07.
//

import Foundation
import UIKit

extension UINavigationController {
    
    /// 배경 white, backButton, tintColor black
//    func configureNavigationBarAppearance(_ color: UIColor) {
//
//        let titleAttrStringOption = [
//            NSAttributedString.Key.foregroundColor: UIColor.black,
//            NSAttributedString.Key.font: UIFont(name: "Cafe24Syongsyong", size: 25)!
//        ]
//
//        let appearance = UINavigationBarAppearance(idiom: .phone)
//        appearance.titleTextAttributes = titleAttrStringOption     // title 설정
//        appearance.largeTitleTextAttributes = titleAttrStringOption
//        appearance.shadowColor = .clear                            // 하단의 가로 선 제거
//        appearance.backgroundColor = color                         // 배경색
//
//        let navigationBarApear = UINavigationBar.appearance()
//        navigationBarApear.compactAppearance = appearance
//        navigationBarApear.standardAppearance = appearance
//        navigationBarApear.scrollEdgeAppearance = appearance
//
//        navigationBarApear.prefersLargeTitles = true
//        navigationBarApear.isTranslucent = true
//
//        self.navigationBar.topItem?.title = ""
//        self.navigationBar.tintColor = .black
//        self.navigationBar.barTintColor = color
//    }
    
//    func configureNavigationWithLargerTitle(_ color: UIColor) {
//        
//        _ = self.navigationBar.then {
//            $0.prefersLargeTitles = true
//            $0.isTranslucent = true
//            $0.shadowImage = UIImage()
//            $0.topItem?.title = ""
//            $0.tintColor = .black
//            $0.barTintColor = color
//        }
//
//    }
    
    
    func configureNavigation(_ color: UIColor, largeTitle: Bool) {
        
        let titleAttrStringOption = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "Cafe24Syongsyong", size: 25)!
        ]
        
        _ = self.navigationBar.then {
            $0.prefersLargeTitles = largeTitle
            $0.isTranslucent = largeTitle
            $0.shadowImage = UIImage()
            $0.topItem?.title = ""
            $0.tintColor = .black
            $0.barTintColor = color
            $0.shadowImage = UIImage()
        }

    }

}
