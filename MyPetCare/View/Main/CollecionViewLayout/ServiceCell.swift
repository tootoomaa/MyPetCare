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
        $0.font = .systemFont(ofSize: 15, weight: .bold)
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
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
    }
    
    private func configureLayout() {
        
        [imageView, titleLabel].forEach {
            contentView.addSubview($0)
        }
        
        imageView.snp.makeConstraints {
            $0.centerY.equalTo(contentView.safeAreaLayoutGuide).offset(-10)
            $0.centerX.equalTo(contentView.safeAreaLayoutGuide)
            $0.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalTo(contentView.safeAreaLayoutGuide)
        }
        
    }
    
}
