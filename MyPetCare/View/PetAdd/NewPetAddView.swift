//
//  NewPetAddView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/08.
//

import Foundation
import UIKit

class NewPetAddView: UIView {
    // MARK: - Propeties
    let padding: CGFloat = 8
    
    let basicTitle = UILabel().then {
        $0.text = "기본 정보"
        $0.font = .systemFont(ofSize: 25, weight: .bold)
    }
    
    let petImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(systemName: "photo")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.gray)
        $0.isUserInteractionEnabled = true
    }
    
    let nameTextField = UITextField().then {
        $0.backgroundColor = .none
        $0.placeholder = "이름을 입력하세요"
        $0.textAlignment = .center
        $0.keyboardType = .namePhonePad
        $0.returnKeyType = .done
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
    }
    
    let maleSegmentController = UISegmentedControl(items: ["아들", "딸"]).then {
        $0.removeBorder()
        $0.selectedSegmentIndex = 0
        $0.backgroundColor = .none
    }
    
    let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.locale = Constants.currentLocale
        $0.maximumDate = Date()
        $0.tintColor = .black
    }
    
    let healthTitle = UILabel().then {
        $0.text = "건강 정보"
        $0.font = .systemFont(ofSize: 25, weight: .bold)
    }
    
    let tableView = UITableView().then {
        $0.backgroundColor = .lightBlue
        $0.separatorStyle = .none
        $0.rowHeight = 50
        $0.register(HealthDataCell.self,
                    forCellReuseIdentifier: HealthDataCell.identifier)
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightBlue
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        layoutMargins = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        let marginGuide = self.layoutMarginsGuide
        
        [basicTitle, petImageView, nameTextField, maleSegmentController, datePicker,
         healthTitle, tableView].forEach {
            addSubview($0)
        }
        
        basicTitle.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(marginGuide)
        }
        
        basicTitle.addButtonBorder(.black, 2)
        
        let viewWidthMinusPadding = Constants.viewWeigth - 30 - 30 // leading, trailing
        petImageView.snp.makeConstraints {
            $0.top.equalTo(basicTitle.snp.bottom).offset(padding*2)
            $0.leading.equalTo(basicTitle)
            $0.height.width.equalTo(viewWidthMinusPadding/2*0.8)
        }
        
        maleSegmentController.snp.makeConstraints {
            $0.centerY.equalTo(petImageView)
            $0.leading.equalTo(snp.centerX).offset(padding)
            $0.trailing.equalTo(marginGuide)
            $0.height.equalTo(25)
        }
        
        nameTextField.snp.makeConstraints {
            $0.bottom.equalTo(maleSegmentController.snp.top).offset(-padding*2)
            $0.height.equalTo(maleSegmentController)
            $0.leading.trailing.equalTo(maleSegmentController)
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(maleSegmentController.snp.bottom).offset(padding*2)
            $0.height.centerX.equalTo(maleSegmentController)
        }
        
        healthTitle.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.bottom).offset(30)
            $0.leading.equalTo(basicTitle)
            $0.trailing.equalTo(marginGuide)
        }
        
        healthTitle.addButtonBorder(.black, 2)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(healthTitle.snp.bottom).offset(padding*2)
            $0.leading.trailing.equalTo(marginGuide)
            $0.height.equalTo(300)
        }
    }
    
}
