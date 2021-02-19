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
    lazy var customEdgeInsets = UIEdgeInsets(top: padding*2, left: padding, bottom: padding, right: padding)
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
    
    var petMaleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.alpha = 0
    }
    
    let petProfilelayout = PetProfileCollecionViewFlowLayout()
    var petProfileCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    let topPadding = PetProfileCollecionViewFlowLayout.BaseLayout.height
    lazy var pfvWidth = Constants.viewWidth-customEdgeInsets.right-customEdgeInsets.left
    lazy var pfvHeight = pfvWidth/2 + topPadding + padding
    lazy var pfvFrame = CGRect(x: 0, y: 0, width: pfvWidth, height: pfvHeight)
    
    lazy var petProfileView = PetProfileView(frame: pfvFrame, topPadding: topPadding, bottomPadding: padding)
    
    lazy var mainFrameTableView = UITableView().then {
        $0.backgroundColor = .none
        
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 300
        
        $0.tableHeaderView = petProfileView
        $0.scrollIndicatorInsets = .zero
        $0.showsVerticalScrollIndicator = false
    }
    
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layoutMargins = customEdgeInsets
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
        }
    }
    
    private func configureLayout() {
        let marginGuide = self.layoutMarginsGuide

        [titleLabel, selectPetImageView, selectedPetName, petMaleImageView,
         mainFrameTableView, petProfileCollectionView].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(marginGuide).offset(padding*2)
            $0.leading.trailing.equalTo(marginGuide)
        }
        
        selectPetImageView.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel)
            $0.trailing.equalTo(marginGuide)
            $0.width.height.equalTo(34)
        }
        
        selectedPetName.snp.makeConstraints {
            $0.trailing.equalTo(selectPetImageView.snp.leading).offset(-3)
            $0.centerY.equalTo(selectPetImageView)
        }
        
        petMaleImageView.snp.makeConstraints {
            $0.trailing.equalTo(selectedPetName.snp.leading).offset(-5)
            $0.centerY.equalTo(selectPetImageView)
            $0.height.equalTo(15)
            $0.width.equalTo(9)
        }
        
        petProfileCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(padding)
            $0.leading.trailing.equalTo(marginGuide)
            $0.height.equalTo(PetProfileCollecionViewFlowLayout.BaseLayout.height)
        }
        
        mainFrameTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(padding*2)
            $0.leading.trailing.bottom.equalTo(marginGuide)
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
            self.petMaleImageView.alpha = 1
            self.selectedPetName.alpha = 1
            self.selectPetImageView.alpha = 1
        } else if offset < 80 && isMainFrameScrolled == true {
            self.petMaleImageView.alpha = 0
            self.selectedPetName.alpha = 0
            self.selectPetImageView.alpha = 0
        }
    }
}
