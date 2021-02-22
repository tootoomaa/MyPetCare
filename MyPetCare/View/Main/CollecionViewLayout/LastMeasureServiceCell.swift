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
    
    let titleLabel = UILabel().then {
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 25)
    }
    
    let showMoreButton = UIButton().then {
        
        let image = UIImage(systemName: "chevron.forward")?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(.black)
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 55, bottom: 5, right: 0)
        $0.setTitle("더보기", for: .normal)
        $0.titleLabel?.font = .dynamicFont(name: "Cafe24Syongsyong", size: 15)
        $0.setTitleColor(.black, for: .normal)
        $0.addCornerRadius(20)
    }

    
    // MARK: - Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addCornerRadius(20)
        addCornerRadius(20)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        let safeGuide = contentView.safeAreaLayoutGuide
        
        [titleLabel,
         showMoreButton].forEach {
            contentView.addSubview($0)
         }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeGuide).offset(10)
            $0.leading.equalTo(safeGuide).offset(20)
        }
        
        showMoreButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.bottom.equalTo(safeGuide).offset(-10)
            $0.trailing.equalTo(safeGuide).offset(-10)
            $0.width.equalTo(80)
            $0.height.equalTo(20)
        }
        
    }
    
}
