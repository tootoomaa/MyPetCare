//
//  MainView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/04.
//

import Foundation
import UIKit

class MainView: UIView {
    
    let padding: CGFloat = 8
    var petNameWidth: CGFloat = 0
    
    // MARK: - Properties
    let titleLabel = UILabel().then {
        $0.text = "My Pets"
        $0.font = .systemFont(ofSize: 30, weight: .bold)
    }
    
    let topSelectCategoryList = ["프로필","건강","기타"]
    
    let petProfilelayout = PetProfileCollecionViewFlowLayout()
    var petProfileCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
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
    
    let serviceTitle = UILabel().then {
        $0.text = "Services"
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 25, weight: .bold)
    }
    
    let serviceFlowLayout = ServiceCollecionViewFlowLayout()
    let serviceColectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    let petEmtpyImage = UIImageView().then {
        $0.image = UIImage(systemName: "house")
    }
    
    let petEmptyLabel = UILabel().then {
        $0.text = "가족을 등록해주세요!"
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGreen
        
        petProfileCollectionView.backgroundColor = .none
        petProfileCollectionView.delegate = petProfilelayout
        petProfileCollectionView.register(PetProfileImageCell.self,
                                          forCellWithReuseIdentifier: PetProfileImageCell.identifier)

        serviceColectionView.backgroundColor = .none
        serviceColectionView.delegate = serviceFlowLayout
        serviceColectionView.register(ServiceCell.self,
                                      forCellWithReuseIdentifier: ServiceCell.identifier)
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        self.layoutMargins = UIEdgeInsets(top: padding*2, left: padding, bottom: padding, right: padding)
        let marginGuide = self.layoutMarginsGuide
        
        [titleLabel, petProfileCollectionView,                      // TopView
         petProfileView,                                            // Pet View
         serviceTitle, serviceColectionView,                        // List UI
        ].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(marginGuide).offset(padding*2)
            $0.leading.equalTo(marginGuide)
        }

        petProfileCollectionView.snp.makeConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(padding)
            $0.leading.trailing.equalTo(marginGuide)
            $0.height.equalTo(PetProfileCollecionViewFlowLayout.BaseLayout.height)
        }
        
        // pet Profile
        let petProfileImageViewWidth = (Constants.viewWeigth-padding*4)
        petProfileView.snp.makeConstraints {
            $0.top.equalTo(petProfileCollectionView.snp.bottom).offset(padding)
            $0.leading.equalTo(self.safeAreaLayoutGuide).offset(padding*2)
            $0.trailing.equalTo(self.safeAreaLayoutGuide).offset(-padding*2)
            $0.height.equalTo(petProfileImageViewWidth/2)
        }
        
        [petImageView, petName, petMaleImageView,
         ageLabel, ageValueLabel, weightLabel, weightValueLabel,
         heightLabel, heightValueLabel].forEach {
            petProfileView.addSubview($0)
        }
        
        petImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(petProfileImageViewWidth/2)
        }
        
        let axisXPadding = petProfileImageViewWidth/2/4
        petName.snp.makeConstraints {
            $0.top.equalTo(petProfileView).offset(25)
            $0.leading.equalTo(petImageView.snp.trailing).offset(10)
            $0.trailing.equalTo(petProfileView.snp.trailing).offset(-10)
        }
        
        petNameWidth = petProfileImageViewWidth/2 - 20
        
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
        
        ///-----------------------------------------------
        /// Service
        serviceTitle.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.bottom).offset(padding*2)
            $0.leading.trailing.equalTo(marginGuide)
        }
        
        serviceColectionView.snp.makeConstraints {
            $0.top.equalTo(serviceTitle.snp.bottom).offset(padding)
            $0.leading.trailing.equalTo(marginGuide)
            $0.bottom.equalTo(marginGuide)
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
    
    // MARK: - View handler
    func configureViewComponentsByPetList(_ isEmpty: Bool) {
        petEmtpyImage.isHidden = !isEmpty
        petEmptyLabel.isHidden = !isEmpty
        ageLabel.isHidden = isEmpty
        weightLabel.isHidden = isEmpty
        heightLabel.isHidden = isEmpty
    }
    
    func configurePetView(pet: Pet) {
        
        petImageView.image = UIImage(data: pet.image ?? Data())
        
        petName.text = pet.name                 // 값 입력
        petName.sizeToFit()                     // 순서 변경 X
//        petName.text = "안녕하세요댕댕이입니다"
//        petName.text = "댕댕이"
        
//        print(petNameWidth)
//        print(petName.intrinsicContentSize.width)
//        print(petName.frame)
        
        //Pet 이름 길이에 따른 성별 마크 위치 수정
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
        
        petMaleImageView.image = UIImage(named: Male(rawValue: pet.male!)!.rawValue )
        
        ageValueLabel.text = "\(pet.age) yrs"
        weightValueLabel.text = "\(pet.weight) kg"
        heightValueLabel.text = "\(pet.height) cm"
        
    }
}
