//
//  NewMainView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/14.
//

import Foundation
import UIKit
import SnapKit
import Then

class NewMainView: UIView {
    // MARK: - UI Layout Controller
    
    let padding: CGFloat = 8
    var petNameWidth: CGFloat = 0
    lazy var customEdgeInsets = UIEdgeInsets(top: padding*2, left: padding, bottom: padding, right: padding)
    
    // MARK: - Properties
    let titleLabel = UILabel().then {
        $0.text = "My Pets"
        $0.font = .systemFont(ofSize: 30, weight: .bold)
    }
    
    let selectedPetName = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
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
    
    // MARK: - View handler
    func configureEmptyViewComponentsByPetList(_ isEmpty: Bool) {
        _ = petProfileView.then {
            $0.petImageView.isHidden = !isEmpty
            $0.petEmptyLabel.isHidden = !isEmpty
            $0.ageLabel.isHidden = isEmpty
            $0.weightLabel.isHidden = isEmpty
            $0.heightLabel.isHidden = isEmpty
        }
        
    }
}
