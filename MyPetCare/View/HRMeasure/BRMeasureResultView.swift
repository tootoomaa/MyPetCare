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
    
    // MARK: - Properties
    let measureInfoLabel = UILabel().then {
        $0.text = "평균 심박수 : 10회/분"
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 30)
        $0.textAlignment = .center
    }
    
    let guideInfoLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 20)
        $0.text = """
            강아지 : 수면 호흡수 6~25\n
                       휴식 호흡수 14~35\n

            고양이 : 수면 호흡수 8~35
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
        
        [measureInfoLabel,
         guideInfoLabel,
         cancelButton, saveButton].forEach {
            addSubview($0)
        }
        
        measureInfoLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(padding*2)
            $0.leading.equalToSuperview().offset(padding*2)
            $0.trailing.equalToSuperview().inset(padding*2)
        }
        
        guideInfoLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(measureInfoLabel)
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
        
        
        
    }
    
}
