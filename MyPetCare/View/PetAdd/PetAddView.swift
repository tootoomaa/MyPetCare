//
//  PetAddView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/07.
//

import Foundation
import UIKit

class PetAddView: UIView {
    // MARK: - Properties
    let padding: CGFloat = 8
    let menuFontSize: CGFloat = 20
    let marginEdgePadding: CGFloat = 30
    
    let petImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.layer.cornerRadius = UIScreen.main.bounds.width/2/2
        $0.image = UIImage(systemName: "photo")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.gray)
        $0.isUserInteractionEnabled = true
    }
    
    let dataInputView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 30
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    lazy var nameLabel = UILabel().then {
        $0.text = "이름"
        $0.font = .systemFont(ofSize: menuFontSize, weight: .semibold)
        $0.textColor = .black
    }
    
    let nameTextField = UITextField().then {
        $0.backgroundColor = .white
        $0.placeholder = "이름을 입력하세요"
        $0.textAlignment = .center
        $0.keyboardType = .namePhonePad
        $0.returnKeyType = .done
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
    }
    
    let buttonLine = UIView().then {
        $0.backgroundColor = .systemGray4
    }
    
    lazy var birthDayLabel = UILabel().then {
        $0.text = "생일"
        $0.font = .systemFont(ofSize: menuFontSize, weight: .semibold)
        $0.textColor = .black
    }
    
    lazy var maleLabel = UILabel().then {
        $0.text = "성별"
        $0.font = .systemFont(ofSize: menuFontSize, weight: .semibold)
        $0.textColor = .black
    }
    
    let maleSegmentController = UISegmentedControl(items: ["아들", "딸"]).then {
        $0.removeBorder()
        $0.selectedSegmentIndex = 0
    }
    
    let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.locale = Constants.currentLocale
        $0.maximumDate = Date()
        $0.tintColor = .black
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
        
        [petImage, dataInputView].forEach {
            addSubview($0)
        }
        
        petImage.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(padding)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(Constants.viewWeigth/2)
            
        }
        
        dataInputView.layoutMargins = UIEdgeInsets(top: marginEdgePadding,
                                                   left: marginEdgePadding,
                                                   bottom: marginEdgePadding,
                                                   right: marginEdgePadding)
        
        let marginGuide = dataInputView.layoutMarginsGuide
        
        dataInputView.snp.makeConstraints {
            $0.top.equalTo(petImage.snp.bottom).offset(padding*2)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(self)
        }
        
        [nameLabel, nameTextField,
         maleLabel, maleSegmentController, buttonLine,
         birthDayLabel, datePicker].forEach {
            addSubview($0)
         }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(dataInputView).offset(30)
            $0.leading.equalToSuperview().offset(30)
            $0.width.equalTo(50)
        }

        nameTextField.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(padding*2)
            $0.trailing.equalToSuperview().offset(-padding*2)
        }
        
        buttonLine.snp.makeConstraints {
            $0.leading.trailing.equalTo(nameTextField)
            $0.bottom.equalTo(nameTextField).offset(3)
            $0.height.equalTo(1)
        }
        
        maleLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(padding*3)
            $0.leading.equalTo(marginGuide)
            $0.width.equalTo(50)
        }
        
        maleSegmentController.snp.makeConstraints {
            $0.centerY.equalTo(maleLabel)
            $0.leading.equalTo(maleLabel.snp.trailing).offset(padding*2)
            $0.trailing.equalTo(marginGuide)
            $0.height.equalTo(maleLabel)
        }
        
        birthDayLabel.snp.makeConstraints {
            $0.top.equalTo(maleLabel.snp.bottom).offset(padding*3)
            $0.leading.equalTo(marginGuide)
            $0.width.equalTo(50)
        }
        
        datePicker.snp.makeConstraints {
            $0.centerY.equalTo(birthDayLabel)
            $0.centerX.equalTo(maleSegmentController)
        }
    }
}
