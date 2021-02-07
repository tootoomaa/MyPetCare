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
    
    let petProfileImageView = UIImageView().then {
        $0.layer.cornerRadius = PetProfileCollecionViewFlowLayout.BaseLayout.collectionViewCellHeight/2
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        
        [petProfileImageView].forEach {
            contentView.addSubview($0)
        }
        
        petProfileImageView.snp.makeConstraints {
            $0.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
        
    }
    
    override func prepareForReuse() {
        self.backgroundColor = .none
        petProfileImageView.image = nil
    }
}
