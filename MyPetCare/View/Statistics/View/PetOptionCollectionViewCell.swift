//
//  PetOptionCollectionViewCell.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/28.
//

import Foundation
import UIKit

class PetOptionCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PetOptionCollectionViewCell"
    
    let selectedBoarderColor: UIColor = .cViolet
    
    lazy var petProfileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .extraGray
        $0.layer.cornerRadius = 25
        $0.layer.borderColor = UIColor.cViolet.cgColor
    }
    
    lazy var selectMarkImage = UIImageView().then {
        let image = UIImage(systemName: "checkmark.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(selectedBoarderColor)
        $0.image = image
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        $0.isHidden = true
    }
    
    override var isSelected: Bool {
        didSet {
            print("Pet Option CEll is Changed", isSelected)
            self.selectMarkImage.isHidden = !isSelected
            self.petProfileImageView.layer.borderWidth = isSelected ? 2 : 0
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
            $0.width.height.equalTo(17)
        }
    }
    
    func configureCell(petObj: PetObject) {
        self.petProfileImageView.image = UIImage(data: (petObj.image!))
        self.petProfileImageView.layer.cornerRadius = 25
    }
    
    override func prepareForReuse() {
        self.backgroundColor = .none
        self.petProfileImageView.image = nil
    }
    
}
