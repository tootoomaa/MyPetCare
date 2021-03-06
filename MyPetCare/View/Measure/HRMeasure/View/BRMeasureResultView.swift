//
//  BRMeasureResultView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/19.
//

import Foundation
import UIKit

class BPMeasureResultView: UIView {
    
    let padding: CGFloat = 16
    var brNumber: Int = 20 {
        didSet {
            
            let numberAttrString = [NSAttributedString.Key.font: UIFont.dynamicFont(name: "Cafe24Syongsyong", size: 35),
                                    NSAttributedString.Key.foregroundColor: UIColor.red]
            let countLabelAttrString = [NSAttributedString.Key.font: UIFont.dynamicFont(name: "Cafe24Syongsyong", size: 25),
                                    NSAttributedString.Key.foregroundColor: UIColor.black]
            
            let attrString = NSMutableAttributedString(string: "\(brNumber)",attributes: numberAttrString)
            attrString.append(NSAttributedString(string: " 회/분", attributes: countLabelAttrString))
            
            self.measureInfoValueLabel.attributedText = attrString
        }
    }
    
    var measureValueByData: (brNumber: Int, measureTime: Int) = (0,0) {
        didSet {
            self.detailMeasureInfoValueLabel.text = "(\(measureValueByData.brNumber)회 \(measureValueByData.measureTime)초)"
        }
    }
    
    var petState: Bool = false {
        didSet {
            guard petState else { return }
            self.petStateLabel.text = "수면 상태"
        }
    }
    
    // MARK: - Properties
    let measureInfoLabel = UILabel().then {
        $0.text = "평균 심박수"
        $0.font = UIFont.dynamicFont(name: "Cafe24Syongsyong", size: 25)
        $0.textAlignment = .center
    }
    
    let petStateLabel = UILabel().then {
        $0.font = UIFont.dynamicFont(name: "Cafe24Syongsyong", size: 15)
        $0.textColor = .systemGray2
        $0.textAlignment = .center
    }
    
    let measureInfoValueLabel = UILabel().then {
        $0.font = UIFont.dynamicFont(name: "Cafe24Syongsyong", size: 30)
        $0.textAlignment = .center
    }
    
    let detailMeasureInfoValueLabel = UILabel().then {
        $0.font = UIFont.dynamicFont(name: "Cafe24Syongsyong", size: 15)
        $0.textAlignment = .center
    }
    
    let guideInfoLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = UIFont.dynamicFont(name: "Cafe24Syongsyong", size: 20)
        $0.textAlignment = .center
        $0.text = """
            [ 강아지 ]
            수면 호흡수 6~25
            휴식 호흡수 14~35\n
            [ 고양이 ]
            수면 호흡수 8~35
            """
    }
    
    let saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .saveButtonColor
        $0.addBorder(.black, 1)
        $0.addCornerRadius(20)
    }
    
    let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = .cancelButtonColor
        $0.addBorder(.black, 1)
        $0.addCornerRadius(20)
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Layout
    
    private func configureView() {
        backgroundColor = UIColor(rgb: 0xf4f9f9)
        
        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        addBorder(.black, 1)
        
        alpha = 0
    }
    
    private func configureLayout() {
        
        [measureInfoLabel, petStateLabel, measureInfoValueLabel,
         detailMeasureInfoValueLabel,
         guideInfoLabel,
         cancelButton, saveButton].forEach {
            addSubview($0)
        }
        
        measureInfoLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(padding*4)
            $0.leading.equalToSuperview().offset(padding*2)
        }
        
        petStateLabel.snp.makeConstraints {
            $0.top.equalTo(measureInfoLabel.snp.bottom)
            $0.centerX.equalTo(measureInfoLabel)
        }
        
        measureInfoValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(measureInfoLabel)
            $0.leading.equalTo(measureInfoLabel.snp.trailing)
            $0.trailing.equalToSuperview().inset(padding*2)
            $0.width.equalTo(measureInfoLabel)
        }
        
        detailMeasureInfoValueLabel.snp.makeConstraints {
            $0.top.equalTo(measureInfoValueLabel.snp.bottom).offset(3)
            $0.centerX.equalTo(measureInfoValueLabel)
        }
        
        guideInfoLabel.snp.makeConstraints {
            $0.leading.equalTo(measureInfoLabel)
            $0.trailing.equalTo(measureInfoValueLabel)
            $0.bottom.equalTo(cancelButton.snp.top).offset(-padding*2)
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(padding)
            $0.bottom.equalToSuperview().inset(padding)
            $0.height.equalTo(45)
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.equalTo(cancelButton.snp.trailing).offset(padding)
            $0.trailing.bottom.equalToSuperview().inset(padding)
            $0.size.equalTo(cancelButton)
        }
        
        brNumber = 30
        
    }
    
}
