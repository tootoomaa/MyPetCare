//
//  BPMeasureView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import UIKit

class HReasureView: UIView {
    
    let padding: CGFloat = 8
    
    // MARK: - Properties
    var petImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    var petName = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 25)
        $0.textAlignment = .center
    }
    
    var petMaleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    var petAge = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 25)
    }
    
    var paddingLabel = UILabel().then {
        $0.text = "|"
        $0.textColor = .lightGray
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 25)
    }
    
    var hrMeasureView = UIView().then {
        $0.backgroundColor = .hrMesaureColor
        $0.layer.cornerRadius = 40
        $0.layer.maskedCorners = [.layerMinXMinYCorner,
                                  .layerMaxXMinYCorner]
    }
    
    var timeSettingView = UIView().then {
        $0.backgroundColor = .none
    }
    
    var timeSettingLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 20, weight: .medium)
        $0.textAlignment = .center
        $0.text = "시간 설정"
    }
    
    let secondSegmentController = UISegmentedControl(items: ["10초", "20초", "30초", "60초"]).then {
        $0.removeBorder()
        $0.selectedSegmentIndex = 0
        $0.layer.borderWidth = 1
        $0.layer.backgroundColor = UIColor.systemGray4.cgColor
    }
    
    let startButton = UIButton().then {
        $0.setTitle("시작", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = Constants.mainColor
        $0.titleLabel?.font = UIFont(name: "Cafe24Syongsyong", size: 40)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.cornerRadius = 20
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .hrMeasureBottomViewColor
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        let safeGuide = self.safeAreaLayoutGuide
        
        [hrMeasureView,
         petMaleImageView, petName, petAge, paddingLabel, petImageView,
         timeSettingView,
         startButton].forEach {
            addSubview($0)
        }
        
        hrMeasureView.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.centerY)
            $0.leading.trailing.bottom.equalTo(safeGuide)
        }
        
        // MARK: - Pet Profile View
        petImageView.snp.makeConstraints {
            $0.top.equalTo(safeGuide).offset(50)
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
        
        // MARK: - Time Setting View
        timeSettingView.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.bottom).offset(padding*2)
            $0.leading.equalTo(safeGuide).offset(padding*2)
            $0.trailing.equalTo(safeGuide).offset(-padding*2)
            $0.height.equalTo(80)
        }
        
        [timeSettingLabel, secondSegmentController].forEach {
            timeSettingView.addSubview($0)
        }
        
        timeSettingLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(padding)
        }
        
        secondSegmentController.snp.makeConstraints {
            $0.top.equalTo(timeSettingLabel.snp.bottom).offset(padding)
            $0.leading.equalToSuperview().offset(padding)
            $0.trailing.equalToSuperview().offset(-padding)
            $0.bottom.equalToSuperview().offset(-padding)
        }
        
        startButton.snp.makeConstraints {
            $0.top.equalTo(timeSettingView.snp.bottom).offset(padding*2)
            $0.leading.trailing.equalTo(timeSettingView)
            $0.bottom.equalTo(safeGuide).offset(-padding*2)
        }
    }
}
