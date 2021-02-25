//
//  MeasureDetailTableViewCell.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/25.
//

import Foundation
import UIKit

class MeasureDetailTableViewCell: UITableViewCell {
    // MARK: - Properties
    static var identifier = "MeasureDetailTableViewCell"
    
    let dateLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 15)
    }
    
    let detailDateLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 15)
    }
    
    let mainValueLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 30)
    }
    
    let valueLabel = UILabel().then {
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 18)
    }
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .white
        
        configureContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureContentView() {
        _ = contentView.then {
            $0.backgroundColor = .systemGray6
            $0.addCornerRadius(20)
            $0.addBorder(.systemGray4, 0.5)
            $0.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.height.equalTo(120)
            }
        }
    }
    
    // MARK: - Configure BRObject UI
    func configureLaytoutWithBRObject(data: BRObject) {
        
        configureBROBbjectLayout()
        
        valueLabel.textColor = .systemGray2
        
        dateLabel.text = TimeUtil().getString(data.createDate!, .yymmdd)
        detailDateLabel.text = TimeUtil().getString(data.createDate!, .hhmm)
        mainValueLabel.text = "\(data.resultBR)회/분"
        valueLabel.text = "\(data.originalBR)회/\(data.userSettingTime)초"
        
    }
    
    private func configureBROBbjectLayout() {
        let safeGuide = contentView.safeAreaLayoutGuide
        [dateLabel, detailDateLabel,
         mainValueLabel, valueLabel].forEach {
            contentView.addSubview($0)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.leading.equalTo(safeGuide).offset(10)
        }
        
        detailDateLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(2)
            $0.centerX.equalTo(dateLabel)
        }
        
        mainValueLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(mainValueLabel.snp.bottom)
            $0.centerX.equalTo(mainValueLabel)
        }
    }
    
    // MARK: - Configure PhysicsObject UI
    func configureLaytoutWithPhysicsObject(data: PhysicsObject) {
        
        dateLabel.text = TimeUtil().getString(data.createDate!, .yymmdd)
        detailDateLabel.text = TimeUtil().getString(data.createDate!, .hhmm)
        mainValueLabel.text = "\(data.height)cm, \(data.weight)kg"
        
        configurePhysicsObject()
    }
    
    private func configurePhysicsObject() {
        let safeGuide = contentView.safeAreaLayoutGuide
        [dateLabel, detailDateLabel,
         mainValueLabel
        // valueLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.leading.equalTo(safeGuide).offset(10)
        }
        
        detailDateLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(2)
            $0.centerX.equalTo(dateLabel)
        }
        
        mainValueLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
