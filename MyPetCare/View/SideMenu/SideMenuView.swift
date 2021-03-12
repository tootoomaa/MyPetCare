//
//  SideMenuView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/03/12.
//

import Foundation
import UIKit

class SideMenuView: UIView {
    
    let padding: CGFloat = 8
    
    // MARK: - Properties
    let titleLabel = UILabel().then {
        $0.text = "사용자 프로필"
        $0.textColor = .black
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 15)
    }
    
    let profileEditButton = UIButton().then {
        let normalImage = UIImage(systemName: "chevron.forward")?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(.black)
        let selectImage = UIImage(systemName: "chevron.forward")?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(.gray)
        $0.setImage(normalImage, for: .normal)
        $0.setImage(selectImage, for: .highlighted)
        
        $0.setTitle("편집", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.gray, for: .highlighted)
        
        $0.imageView?.contentMode = .scaleAspectFit
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 40, bottom: 5, right: 0)
        
        $0.titleLabel?.font = .dynamicFont(name: "Cafe24Syongsyong", size: 13)
        $0.addCornerRadius(10)
    }
    
    let userProfileImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = Constants.userEmptyImage
    }
    
    let userNameLabel = UILabel().then {
        $0.text = "asdfasf"
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 20)
    }
    
    let sideMenuTableView = UITableView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure Layout
    private func configureLayout() {
        
        [titleLabel, profileEditButton,
         userProfileImage, userNameLabel,
         sideMenuTableView].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalTo(safeAreaLayoutGuide).offset(padding*2)
        }
        
        profileEditButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalTo(safeAreaLayoutGuide).offset(-padding)
            $0.width.equalTo(65)
            $0.height.equalTo(20)
        }
        
        userProfileImage.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(padding)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(150)
//            $0.leading.trailing.equalTo(safeAreaLayoutGuide).inset(padding*2)
//            $0.height.equalTo(Constants.sideMenuWidth-padding*4)
        }
        
        userNameLabel.snp.makeConstraints {
            $0.top.equalTo(userProfileImage.snp.bottom).offset(padding)
            $0.centerX.equalToSuperview()
        }
        
        sideMenuTableView.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(padding)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}
