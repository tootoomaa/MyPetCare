//
//  PetProfileView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/14.
//

import Foundation
import UIKit

class PetProfileView: UIView {
    
    let padding: CGFloat = 8
    let petNameWidth: CGFloat
    
    // MARK: - Properties
    var petProfileView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    var petImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    var petName = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 25, weight: .bold)
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }
    
    var petMaleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    var ageLabel = UILabel().then {
        $0.text = "Age"
        $0.font = .systemFont(ofSize: 11, weight: .semibold)
        $0.textColor = .systemGray2
    }
    
    var ageValueLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    var weightLabel = UILabel().then {
        $0.text = "Weight"
        $0.font = .systemFont(ofSize: 11, weight: .semibold)
        $0.textColor = .systemGray2
    }
    
    var weightValueLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    var heightLabel = UILabel().then {
        $0.text = "Height"
        $0.font = .systemFont(ofSize: 11, weight: .semibold)
        $0.textColor = .systemGray2
    }
    
    var heightValueLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    let editButton = UIButton().then {
        $0.setTitle("  eidt", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMinYCorner]
    }
    
    let deleteButton = UIButton().then {
        $0.setTitle("  delete", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .red
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMaxXMaxYCorner]
    }
    
    let petEmtpyImage = UIImageView().then {
        $0.image = UIImage(systemName: "house")
    }
    
    let petEmptyLabel = UILabel().then {
        $0.text = "가족을 등록해주세요!"
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    // MARK: - Life Cycle
    
    init(frame: CGRect, topPadding: CGFloat, bottomPadding: CGFloat) {
        
        petNameWidth = frame.size.width/2 - 20
        super.init(frame: frame)
        
        
        configureLayout(topPadding, bottomPadding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout(_ topPadding: CGFloat, _ bottomPadding: CGFloat) {
        
        [editButton, deleteButton, petProfileView].forEach {
            addSubview($0)
        }
        
        petProfileView.snp.makeConstraints {
            // For PetProfileCollectionView Padding
            $0.top.equalToSuperview().offset(topPadding)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-bottomPadding)
        }
        
        editButton.snp.makeConstraints {
            $0.top.trailing.equalTo(petProfileView)
            $0.width.equalTo(120)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom)
            $0.trailing.width.equalTo(editButton)
            $0.bottom.equalTo(petProfileView)
            $0.height.equalTo(editButton).multipliedBy(0.3)
        }
        
        [petImageView, petName, petMaleImageView,
         ageLabel, ageValueLabel, weightLabel, weightValueLabel,
         heightLabel, heightValueLabel].forEach {
            petProfileView.addSubview($0)
        }
        
        petImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.equalTo(self.snp.centerX)
        }
        
        let axisXPadding = self.frame.size.width/2/4
        petName.snp.makeConstraints {
            $0.top.equalTo(petProfileView).offset(25)
            $0.leading.equalTo(petImageView.snp.trailing).offset(10)
            $0.trailing.equalTo(petProfileView.snp.trailing).offset(-10)
        }
        
        ageLabel.snp.makeConstraints {
            $0.top.equalTo(petName.snp.bottom).offset(20)
            $0.centerX.equalTo(petImageView.snp.trailing).offset(axisXPadding*0.8)
        }
        
        ageValueLabel.snp.makeConstraints {
            $0.top.equalTo(ageLabel.snp.bottom)
            $0.leading.equalTo(ageLabel)
        }
        
        weightLabel.snp.makeConstraints {
            $0.centerY.equalTo(ageLabel)
            $0.centerX.equalTo(petImageView.snp.trailing).offset(axisXPadding*2.5)
        }
        
        weightValueLabel.snp.makeConstraints {
            $0.centerY.equalTo(ageValueLabel)
            $0.leading.equalTo(weightLabel)
        }
        
        heightLabel.snp.makeConstraints {
            $0.top.equalTo(ageValueLabel.snp.bottom).offset(20)
            $0.leading.equalTo(ageLabel)
        }

        heightValueLabel.snp.makeConstraints {
            $0.leading.equalTo(heightLabel)
            $0.top.equalTo(heightLabel.snp.bottom)
        }
        
        [petEmtpyImage, petEmptyLabel].forEach {                               // Empty
            petProfileView.addSubview($0)
        }
        petEmtpyImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-padding*2)
            $0.width.height.equalTo(100)
        }

        petEmptyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(petEmtpyImage.snp.bottom).offset(padding)
        }
    }
    
    // MARK: - View Hander
    func configureEmptyViewComponentsByPetList(_ isEmpty: Bool) {
        petEmtpyImage.isHidden = !isEmpty
        petEmptyLabel.isHidden = !isEmpty
        ageLabel.isHidden = isEmpty
        weightLabel.isHidden = isEmpty
        heightLabel.isHidden = isEmpty
    }
    
    /// Pet Profile View 갱신
    func configurePetView(pet: PetObject) {
        
        petImageView.image = UIImage(data: pet.image ?? Data())
        
        petName.text = pet.name                 // 값 입력
        petName.sizeToFit()                     // 순서 변경 X
        
        //Pet 이름 길이에 따른 성별 마크 위치 수정
        petMaleImageView.snp.removeConstraints()
        petMaleImageView.snp.makeConstraints {
            $0.centerY.equalTo(petName)
            if petNameWidth > petName.intrinsicContentSize.width {
                // 정상 길이 처리
                $0.centerX.equalTo(petName.snp.centerX).offset(-petName.intrinsicContentSize.width/2-10)
            } else {
                // 긴 이름 처리
                $0.leading.equalTo(petImageView.snp.trailing)
                $0.trailing.equalTo(petName.snp.leading)
            }
            $0.width.equalTo(10.4)
            $0.height.equalTo(20)
        }
        
        petMaleImageView.image = UIImage(named: Male(rawValue: pet.male!)!.rawValue)
        
        ageValueLabel.text = "\(pet.age) yrs"
        weightValueLabel.text = "\(pet.weight) kg"
        heightValueLabel.text = "\(pet.height) cm"
    }
}