//
//  UIView+Extension.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/08.
//

import Foundation
import UIKit

extension UIView {
    
    func addButtonBorder(_ color: UIColor, _ height: CGFloat) {
        
        let view = UIView().then {
            $0.backgroundColor = color
        }
        
        self.addSubview(view)
        view.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(1)
            $0.height.equalTo(height)
        }
        
    }
    
}
