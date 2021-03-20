//
//  SideMenuTableViewCell.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/03/14.
//

import Foundation
import UIKit

class SideMenuTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "SideMenuTableViewCell"
    
    let titleLabel = UILabel().then {
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 18)
        $0.textColor = .black
    }
    
    let sideImageview = UIImageView().then {
        let image = UIImage(systemName: "chevron.right")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.black)
        $0.image = image
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Layout
    private func configureLayout() {
        let safeGuide = contentView.safeAreaLayoutGuide
        
        [titleLabel, sideImageview].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.leading.equalTo(safeGuide).offset(16)
        }
        
        sideImageview.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalTo(safeGuide.snp.trailing).offset(-16)
            $0.size.equalTo(20)
        }
    }
    
    // MARK: - Cell Configure
    func configureCell(_ sideMenuType: SideMenus) {
        
        self.titleLabel.text = sideMenuType.rawValue
        
    }
}
