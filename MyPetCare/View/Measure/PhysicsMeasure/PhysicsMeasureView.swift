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
    var measureType: MeasureServiceType
    
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
    
    let weightTitleLabel = UILabel().then {
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 40)
    }
    
    let weightTextField = UITextField().then {
        $0.placeholder = "입력"
        $0.keyboardType = .numberPad
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 40)
        $0.textAlignment = .right
        $0.adjustsFontSizeToFitWidth = true
    }
    
    let weightValueLabel = UILabel().then {
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 30)
    }
    
    let brInputCountInfoLabel = UILabel().then {
        $0.text = "(1분 기준)"
        $0.textColor = .systemGray2
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 16)
    }
    
    let petStateButton = UISwitch()
    
    let petStateLabel = UILabel().then {
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 15)
        $0.text = "수면 off"
        $0.textAlignment = .right
    }
    
    // MARK: - Init
    init(type: MeasureServiceType) {
        self.measureType = type
        super.init(frame: .zero)
        
        petStateButton .isHidden = measureType != .sleepBreathRate
        petStateLabel.isHidden = measureType != .sleepBreathRate
        brInputCountInfoLabel.isHidden = measureType != .sleepBreathRate
        weightValueLabel.text = measureType == .weight ? "kg" : "회"
        weightTitleLabel.text = measureType == .weight ? "체중" : "호흡수"
        
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
         brInputCountInfoLabel, petStateButton, petStateLabel,
         weightTitleLabel, weightTextField, weightValueLabel].forEach {
            addSubview($0)
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
        
        weightTitleLabel.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.bottom).offset(20)
            $0.centerX.equalTo(petImageView)
        }
        
        weightValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(weightTitleLabel)
            $0.trailing.equalTo(safeGuide).inset(30)
            $0.width.equalTo(40)
        }
        
        brInputCountInfoLabel.snp.makeConstraints {
            $0.top.equalTo(weightValueLabel.snp.bottom).offset(padding)
            $0.centerX.equalTo(weightValueLabel.snp.leading)
        }
        
        weightTextField.snp.makeConstraints {
            $0.centerY.equalTo(weightTitleLabel.snp.centerY)
            $0.leading.equalTo(weightTitleLabel.snp.trailing).offset(20)
            $0.trailing.equalTo(weightValueLabel.snp.leading).offset(-10)
        }
        
        petStateButton.snp.makeConstraints {
            $0.top.equalTo(brInputCountInfoLabel.snp.bottom).offset(padding*2)
            $0.trailing.equalTo(brInputCountInfoLabel)
        }
        
        petStateLabel.snp.makeConstraints {
            $0.trailing.equalTo(petStateButton.snp.leading).offset(-padding-3)
            $0.centerY.equalTo(petStateButton)
        }
    }
}
