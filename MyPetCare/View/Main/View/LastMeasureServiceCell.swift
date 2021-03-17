//
//  LastMeasureServiceCell.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/22.
//

import Foundation
import UIKit

class LastMeasureServiceCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "LastMeasureServiceCell"
    
    let cellType: MainFrameMenuType
    
    let customBackgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.addCornerRadius(20)
    }
    
    let titleLabel = UILabel().then {
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 13)
    }
    
    let valeuLabel = UILabel().then {
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 35)
        $0.text = "20kg, 70cm"
        $0.textAlignment = .center
    }
    
    let petStateLabel = UILabel().then {
        $0.backgroundColor = .systemGray2
        $0.text = "수면"
        $0.textColor = .white
        $0.addCornerRadius(4)
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 13)
        $0.isHidden = true
    }
    
    let showMoreButton = UIButton().then {
        let normalImage = UIImage(systemName: "chevron.forward")?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(.black)
        let selectImage = UIImage(systemName: "chevron.forward")?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(.gray)
        $0.setImage(normalImage, for: .normal)
        $0.setImage(selectImage, for: .highlighted)
        
        $0.setTitle("더보기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.gray, for: .highlighted)
        
        $0.imageView?.contentMode = .scaleAspectFit
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 40, bottom: 5, right: 0)
        
        $0.titleLabel?.font = .dynamicFont(name: "Cafe24Syongsyong", size: 13)
        $0.addCornerRadius(10)
    }
    
    // MARK: - Life cycle
    init(_ cellType: MainFrameMenuType) {
        
        self.cellType = cellType
        super.init(style: .default, reuseIdentifier: LastMeasureServiceCell.identifier)
        
        backgroundColor = Constants.mainColor
        addCornerRadius(20)
        
        contentView.backgroundColor = Constants.mainColor
        contentView.addCornerRadius(20)
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        let safeGuide = customBackgroundView.safeAreaLayoutGuide
        
        contentView.addSubview(customBackgroundView)
        customBackgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(120)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        [titleLabel, valeuLabel, petStateLabel,
         showMoreButton].forEach {
            customBackgroundView.addSubview($0)
         }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeGuide).offset(10)
            $0.leading.equalTo(safeGuide).offset(20)
        }
        
        petStateLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(titleLabel)
        }
        
        valeuLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        showMoreButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(safeGuide).offset(-8)
            $0.width.equalTo(65)
            $0.height.equalTo(20)
        }
        
    }
    
}
