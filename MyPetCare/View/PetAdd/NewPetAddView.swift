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
    lazy var viewWidthMinusPadding = Constants.viewWidth - 30 - 30 // leading, trailing

    let basicTitle = UILabel().then {
        $0.text = "기본 정보"
        $0.font = .systemFont(ofSize: 25, weight: .bold)
    }
    
    var petImageView = UIImageView().then {
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
    
    let maleSegmentController = UISegmentedControl(
        items: Male.allCases.map{$0.rawValue}
    ).then {
        $0.removeBorder(nomal: .white, selected: .lightGreen, centerBoarderWidth: 0.5)
        $0.selectedSegmentIndex = 0
        $0.backgroundColor = .none
        $0.addBorder(.black, 0.5)
    }
    
    let sepicesSegmentController = UISegmentedControl(
        items: SpeciesType.allCases.map{$0.rawValue}
    ).then {
        $0.removeBorder(nomal: .white, selected: .lightOrange, centerBoarderWidth: 0.5)
        $0.selectedSegmentIndex = 0
        $0.backgroundColor = .none
        $0.addBorder(.black, 0.5)
    }
    
    let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.locale = Constants.currentLocale
        $0.maximumDate = Date()
        $0.tintColor = .black
    }
    
    let infoLabel = UILabel().then {
        $0.text = "프로필사진까지 등록해야 저장이 가능합니다."
        $0.textColor = .systemGray3
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .extraLightPink
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        layoutMargins = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        let marginGuide = self.layoutMarginsGuide
        
        [basicTitle, petImageView,
         nameTextField, maleSegmentController, sepicesSegmentController, datePicker,
         infoLabel,
        ].forEach {
            addSubview($0)
        }
        
        basicTitle.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(marginGuide)
        }
        
        basicTitle.addButtonBorder(.black, 2)
        
        petImageView.snp.makeConstraints {
            $0.top.equalTo(basicTitle.snp.bottom).offset(padding*4)
            $0.leading.equalTo(basicTitle)
            $0.height.width.equalTo(viewWidthMinusPadding/2*0.8)
        }
        
        maleSegmentController.snp.makeConstraints {
            $0.leading.lessThanOrEqualTo(snp.centerX).offset(padding)
            $0.trailing.greaterThanOrEqualTo(marginGuide)
            $0.bottom.equalTo(petImageView.snp.centerY).offset(-padding)
            $0.height.equalTo(25)
        }
        
        sepicesSegmentController.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.centerY).offset(padding)
            $0.leading.trailing.height.equalTo(maleSegmentController)
        }
        
        nameTextField.snp.makeConstraints {
            $0.bottom.equalTo(maleSegmentController.snp.top).offset(-padding*2)
            $0.height.equalTo(maleSegmentController)
            $0.leading.trailing.equalTo(maleSegmentController)
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(sepicesSegmentController.snp.bottom).offset(padding*2)
            $0.height.centerX.equalTo(sepicesSegmentController)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(padding*4)
            $0.centerX.equalTo(safeAreaLayoutGuide)
        }
    }
}
