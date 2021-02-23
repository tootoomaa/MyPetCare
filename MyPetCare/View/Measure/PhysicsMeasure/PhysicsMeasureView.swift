//
//  PhysicsMeasureView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/23.
//

import Foundation
import UIKit

class PhysicsMeasureView: UIView {
    
    let padding: CGFloat = 8
    
    // MARK: - Properties
    var petImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    var petName = UILabel().then {
        $0.textColor = .black
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 25)
        $0.textAlignment = .center
    }
    
    var petMaleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    var petAge = UILabel().then {
        $0.textColor = .black
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 25)
    }
    
    var paddingLabel = UILabel().then {
        $0.text = "|"
        $0.textColor = .lightGray
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 25)
    }
    
    var hrMeasureView = UIView().then {
        $0.backgroundColor = .hrMesaureColor
        $0.layer.maskedCorners = [.layerMinXMinYCorner,
                                  .layerMaxXMinYCorner]
        $0.addCornerRadius(20)
    }
    
    let heightTitleLabel = UILabel().then {
        $0.text = "키"
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 40)
    }
    
    let heightTextField = UITextField().then {
        $0.placeholder = "입력"
        $0.keyboardType = .numberPad
        $0.returnKeyType = .next
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 40)
        $0.enablesReturnKeyAutomatically = true
    }
    
    let heightValueLabel = UILabel().then {
        $0.text = "cm"
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 30)
    }
    
    let weightTitleLabel = UILabel().then {
        $0.text = "체중"
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 40)
    }
    
    let weightTextField = UITextField().then {
        $0.placeholder = "입력"
        $0.keyboardType = .numberPad
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 40)
    }
    
    let weightValueLabel = UILabel().then {
        $0.text = "kg"
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 30)
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .hrMeasureBottomViewColor
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        let safeGuide = safeAreaLayoutGuide
        
        [hrMeasureView,
         petMaleImageView, petName, petAge, paddingLabel, petImageView,
         heightTitleLabel, heightTextField, heightValueLabel,
         weightTitleLabel, weightTextField, weightValueLabel].forEach { addSubview($0)
         }
        
        hrMeasureView.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.centerY)
            $0.leading.trailing.bottom.equalTo(safeGuide)
        }
        
        // MARK: - Pet Profile View
        petImageView.snp.makeConstraints {
            $0.top.equalTo(safeGuide).offset(30)
            $0.leading.equalTo(hrMeasureView.snp.leading).offset(30)
            $0.width.height.equalTo(Constants.viewWidth/4)
        }
        
        petMaleImageView.snp.makeConstraints {
            $0.leading.equalTo(petImageView.snp.trailing).offset(padding*2)
            $0.bottom.equalTo(hrMeasureView.snp.top).offset(-padding)
            $0.width.equalTo(10)
            $0.height.equalTo(30)
        }
        
        petName.snp.makeConstraints {
            $0.leading.equalTo(petMaleImageView.snp.trailing).offset(padding)
            $0.centerY.equalTo(petMaleImageView)
        }
        
        paddingLabel.snp.makeConstraints {
            $0.leading.equalTo(petName.snp.trailing).offset(padding)
            $0.centerY.equalTo(petName)
        }
        
        petAge.snp.makeConstraints {
            $0.leading.equalTo(paddingLabel.snp.trailing).offset(padding)
            $0.centerY.equalTo(paddingLabel)
        }
        
        heightTitleLabel.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.bottom).offset(20)
            $0.centerX.equalTo(petImageView)
        }
        
        heightValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(heightTitleLabel.snp.centerY)
            $0.trailing.equalTo(safeGuide).inset(35)
        }
        
        heightTextField.snp.makeConstraints {
            $0.centerY.equalTo(heightTitleLabel.snp.centerY)
            $0.trailing.equalTo(heightValueLabel.snp.leading).offset(-10)
        }
        
        weightTitleLabel.snp.makeConstraints {
            $0.top.equalTo(heightTitleLabel.snp.bottom).offset(20)
            $0.centerX.equalTo(petImageView)
        }
        
        weightValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(weightTitleLabel.snp.centerY)
            $0.trailing.equalTo(safeGuide).inset(35)
        }
        
        weightTextField.snp.makeConstraints {
            $0.centerY.equalTo(weightTitleLabel.snp.centerY)
            $0.trailing.equalTo(weightValueLabel.snp.leading).offset(-10)
        }
    }
}
