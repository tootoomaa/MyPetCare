//
//  ServiceCell.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

import Foundation
import UIKit

class ServiceCell: UICollectionViewCell {
    static let identifier = "ServiceCell"
    
    let imageView = UIImageView()
    
    let titleLabel = UILabel().then {
        $0.text = "서비스"
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 15)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureContentView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureContentView() {
        contentView.backgroundColor = .serviceColor
        contentView.layer.cornerRadius = 20
    }
    
    private func configureLayout() {
        
        [titleLabel].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalTo(contentView.safeAreaLayoutGuide)
        }
        
    }
    
}
