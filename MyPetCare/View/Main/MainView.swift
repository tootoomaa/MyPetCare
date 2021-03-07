//
//  MainView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/14.
//

import Foundation
import UIKit
import SnapKit
import Then

class MainView: UIView {
    // MARK: - UI Layout Controller
    
    let padding: CGFloat = 8
    var petNameWidth: CGFloat = 0
    var isMainFrameScrolled = false
    
    // MARK: - Properties
    let titleLabel = UILabel().then {
        $0.text = "My Pets"
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 30)
    }
    
    let selectedPetName = UILabel().then {
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 20)
        $0.alpha = 0
    }
    
    let selectPetImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 17
        $0.alpha = 0
    }
    
    var selectedPetMaleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.alpha = 0
    }
    
    let petProfilelayout = PetProfileCollecionViewFlowLayout()
    var petProfileCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    var petProfileView: PetProfileView
    
    lazy var mainFrameTableView = UITableView().then {
        $0.backgroundColor = .none
        
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 300
        
        $0.tableHeaderView = petProfileView
        $0.scrollIndicatorInsets = .zero
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
    }
    
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        
        let topPadding = PetProfileCollecionViewFlowLayout.BaseLayout.height
        let pfvWidth = frame.width-padding*2
        let pfvHeight = pfvWidth/2 + topPadding + padding
        let pfvFrame = CGRect(x: 0, y: 0, width: pfvWidth, height: pfvHeight)
        
        petProfileView = PetProfileView(frame: pfvFrame, topPadding: topPadding, bottomPadding: padding)
        
        super.init(frame: frame)
        
        self.layoutMargins = UIEdgeInsets(top: padding*2,
                                          left: padding,
                                          bottom: padding,
                                          right: padding)
        
        backgroundColor = Constants.mainColor
        
        configurePetProfileCollectionView()
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurePetProfileCollectionView() {
        _ = petProfileCollectionView.then {
            $0.backgroundColor = .none
            $0.delegate = petProfilelayout
            $0.register(PetProfileImageCell.self,
                        forCellWithReuseIdentifier: PetProfileImageCell.identifier)
            $0.layer.cornerRadius = 20
            $0.showsHorizontalScrollIndicator = false
        }
    }
    
    private func configureLayout() {
        let marginGuide = self.layoutMarginsGuide

        [titleLabel,
         selectPetImageView, selectedPetName, selectedPetMaleImageView,
         mainFrameTableView,
         petProfileCollectionView].forEach {
            addSubview($0)
        }
        
        // For Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(marginGuide).offset(padding*2)
            $0.leading.trailing.equalTo(marginGuide)
        }
        
        // For Selcted Pet Info When MainFrame TableView Scrolled
        selectPetImageView.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel)
            $0.trailing.equalTo(marginGuide)
            $0.width.height.equalTo(34)
        }
        
        selectedPetName.snp.makeConstraints {
            $0.trailing.equalTo(selectPetImageView.snp.leading).offset(-3)
            $0.centerY.equalTo(selectPetImageView)
        }
        
        selectedPetMaleImageView.snp.makeConstraints {
            $0.trailing.equalTo(selectedPetName.snp.leading).offset(-5)
            $0.centerY.equalTo(selectPetImageView)
            $0.height.equalTo(15)
            $0.width.equalTo(9)
        }
        
        // Pet Collection View bottom at Title
        petProfileCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(padding)
            $0.leading.trailing.equalTo(marginGuide)
            $0.height.equalTo(PetProfileCollecionViewFlowLayout.BaseLayout.height)
        }
        
        // Main Frame TableView
        mainFrameTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(padding*2) // <--오류
            $0.leading.trailing.equalTo(marginGuide)
            $0.bottom.equalToSuperview()
        }   
    }
    
    // MARK: - Animation Hander
    func setOriginalOffsetPetProfileView() {
        UIView.animate(withDuration: 0.1) {
            self.petProfileView.dashBoardView.center.x = self.petProfileView.center.x
        }
    }
    
    func presentPetProfileCollectionView() {
        UIView.animate(withDuration: 0.3) {
            self.petProfileCollectionView.center.y += 20
            self.petProfileCollectionView.alpha = 1
        }
    }
    
    func hidePetProfileCollectionView() {
        UIView.animate(withDuration: 0.3) {
            self.petProfileCollectionView.center.y -= 20
            self.petProfileCollectionView.alpha = 0
        }
    }
    
    func mainFrameTableViewAnimationByScroll() {
        // Pet Profile Collection View Animation
        let offset = self.mainFrameTableView.contentOffset.y
        if offset > 20  && isMainFrameScrolled == false {
            
            isMainFrameScrolled = true
            UIView.animate(withDuration: 0.3) {
                self.petProfileCollectionView.center.y -= 20
                self.petProfileCollectionView.alpha = 0
                
            }
            
        } else if offset < 10 && isMainFrameScrolled == true {
            
            isMainFrameScrolled = false
            UIView.animate(withDuration: 0.3) {
                self.petProfileCollectionView.center.y += 20
                self.petProfileCollectionView.alpha = 1

            }
        }
        
        // Selected Pet Display Animation
        if offset > 80 && isMainFrameScrolled == true {
            self.selectedPetMaleImageView.alpha = 1
            self.selectedPetName.alpha = 1
            self.selectPetImageView.alpha = 1
        } else if offset < 80 && isMainFrameScrolled == true {
            self.selectedPetMaleImageView.alpha = 0
            self.selectedPetName.alpha = 0
            self.selectPetImageView.alpha = 0
        }
    }
    
    // MARK: - UI Data Setter
    func configureSelectedPetData(pet: PetObject) {
        guard let petMale = pet.male,
              let petImage = pet.image,
              let petName = pet.name else { // 초기화
            selectedPetName.text = ""
            selectPetImageView.image = nil
            selectedPetMaleImageView.image = nil
            return
        }
        selectedPetMaleImageView.image = Male(rawValue: petMale)?.getPetMaleImage
        selectedPetName.text = petName
        selectPetImageView.image = UIImage(data: petImage)
    }
}
