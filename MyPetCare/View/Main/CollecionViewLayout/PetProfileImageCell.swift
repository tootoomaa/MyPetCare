//
//  MainPetsProfileImageCell.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/04.
//

import Foundation
import UIKit

class PetProfileImageCell: UICollectionViewCell {
    
    static let identifier = "MainPetsProfileImageCell"
    
    let selectedBoarderColor: UIColor = .cViolet
    
    let petProfileImageView = UIImageView().then {
        $0.layer.cornerRadius = PetProfileCollecionViewFlowLayout.BaseLayout.collectionViewCellHeight/2
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .extraGray
    }
    
    lazy var selectMarkImage = UIImageView().then {
        let image = UIImage(systemName: "checkmark.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(selectedBoarderColor)
        $0.image = image
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    override var isSelected: Bool {
        didSet {
            self.selectMarkImage.isHidden = !isSelected
            
            petProfileImageView.layer.borderWidth = isSelected ? 2 : 0
            petProfileImageView.layer.borderColor = selectedBoarderColor.cgColor
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        
        [petProfileImageView, selectMarkImage].forEach {
            contentView.addSubview($0)
        }
        
        petProfileImageView.snp.makeConstraints {
            $0.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
        
        selectMarkImage.snp.makeConstraints {
            $0.bottom.trailing.equalTo(contentView.safeAreaLayoutGuide)
            $0.width.height.equalTo(20)
        }
        
    }
    
    override func prepareForReuse() {
        self.backgroundColor = .none
        petProfileImageView.image = nil
    }
    
}
