//
//  MeasureDetailTableViewCell.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/25.
//

import Foundation
import UIKit

class MeasureDetailTableViewCell: UITableViewCell {
    
    let padding: CGFloat = 8
    
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
    
    let petStateLabel = UILabel().then {
        $0.backgroundColor = .systemGray2
        $0.text = "수면"
        $0.textColor = .white
        $0.addCornerRadius(4)
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 18)
        $0.isHidden = true
    }
    
    let bottomView = UIView().then {
        $0.backgroundColor = .systemGray2
    }
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure BRObject UI
    func configureLaytoutWithBRObject(data: BRObject) {
        
        configureBROBbjectLayout()
        
        valueLabel.textColor = .systemGray2
        
        dateLabel.text = TimeUtil().getString(data.createDate!, .yymmdd)
        detailDateLabel.text = TimeUtil().getString(data.createDate!, .hhmm)
        mainValueLabel.text = "\(data.resultBR)회/분"
        valueLabel.text = "\(data.originalBR)회/\(data.userSettingTime)초"
        
        if data.measureType == MeasureServiceType.sleepBreathRate.rawValue {
            petStateLabel.isHidden = false              // 수면 상태일 때 보여줌
        }
    }
    
    private func configureBROBbjectLayout() {
        [dateLabel, detailDateLabel,
         mainValueLabel, valueLabel,
         petStateLabel, bottomView].forEach {
            contentView.addSubview($0)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(padding*2)
            $0.bottom.equalTo(contentView.snp.centerY)
        }
        
        detailDateLabel.snp.makeConstraints {
            $0.leading.equalTo(padding*2)
            $0.top.equalTo(contentView.snp.centerY)
        }
        
        mainValueLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalTo(contentView.snp.trailing).inset(padding*2)
        }
        
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(mainValueLabel.snp.bottom)
            $0.centerX.equalTo(mainValueLabel)
        }
        
        petStateLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(mainValueLabel.snp.leading).offset(-10)
        }
        
        bottomView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    // MARK: - Configure PhysicsObject UI
    func configureLaytoutWithPhysicsObject(data: PhysicsObject) {
        
        dateLabel.text = TimeUtil().getString(data.createDate!, .yymmdd)
        detailDateLabel.text = TimeUtil().getString(data.createDate!, .hhmm)
        mainValueLabel.text = "\(data.weight)kg"
        
        configurePhysicsObject()
    }
    
    private func configurePhysicsObject() {
        [dateLabel, detailDateLabel,
         mainValueLabel,
         bottomView].forEach {
            contentView.addSubview($0)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(padding*2)
            $0.bottom.equalTo(contentView.snp.centerY)
        }
        
        detailDateLabel.snp.makeConstraints {
            $0.leading.equalTo(padding*2)
            $0.top.equalTo(contentView.snp.centerY)
        }
        
        mainValueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(contentView.snp.trailing).inset(padding*2)
        }
        
        bottomView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    // MARK: - Configure chart Detail Data
    func configureChartDetailData(data: ChartDetailValue) {
        
        switch data.type {
        
        case .breathRate, .sleepBreathRate:
            configureBROBbjectLayout()
            valueLabel.textColor = .systemGray2
            
            detailDateLabel.text = TimeUtil().getString(data.createDate, .hhmm)
            mainValueLabel.text = "\(data.value)회/분"
            
            guard let userMeasureDetailData = data.brOptionValue else { return }
            valueLabel.text = "\(userMeasureDetailData.value)회/\(userMeasureDetailData.userMeasuerTiem)초"
            
            if data.type == .sleepBreathRate  {
                petStateLabel.isHidden = false              // 수면 상태일 때 보여줌
            }
            
            break
            
        case .weight:
            configurePhysicsObject()
//            dateLabel.text = TimeUtil().getString(data.createDate, .yymmdd)
            detailDateLabel.text = TimeUtil().getString(data.createDate, .hhmm)
            mainValueLabel.text = "\(data.value)kg"
            break
        }
        
        self.detailDateLabel.snp.remakeConstraints {
            $0.leading.equalTo(padding*2)
            $0.centerY.equalTo(contentView.snp.centerY)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        [dateLabel, detailDateLabel,
         mainValueLabel, valueLabel,
         petStateLabel, bottomView].forEach {
            $0.removeFromSuperview()
         }
        
        self.petStateLabel.isHidden = true
        self.valueLabel.text = ""
    }
}
