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
        let petProfileViewWidth = frame.width-padding*2
        let petProfileViewHeight = petProfileViewWidth/2 + topPadding + padding
        let pfvFrame = CGRect(x: 0, y: 0, width: petProfileViewWidth, height: petProfileViewHeight)
        
        petProfileView = PetProfileView(frame: pfvFrame, topPadding: topPadding, bottomPadding: padding)
        
        super.init(frame: frame)
        
        self.layoutMargins = UIEdgeInsets(top: 0,
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

        [mainFrameTableView,
         petProfileCollectionView].forEach {
            addSubview($0)
        }
        
        // Pet Collection View bottom at Title
        petProfileCollectionView.snp.makeConstraints {
            $0.top.equalTo(marginGuide)
            $0.leading.trailing.equalTo(marginGuide)
            $0.height.equalTo(PetProfileCollecionViewFlowLayout.BaseLayout.height)
        }
        
        // Main Frame TableView
        mainFrameTableView.snp.makeConstraints {
            $0.top.equalTo(marginGuide).offset(padding) // <--오류
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
    }
}
