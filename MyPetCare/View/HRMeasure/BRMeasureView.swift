//
//  BRMeasureView.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import UIKit

class BRMeasureView: UIView {
    
    let padding: CGFloat = 8
    let cancelButtonHeight: CGFloat = 50
    
    // MARK: - Properties
    var petImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    var petName = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 25)
        $0.textAlignment = .center
    }
    
    var petMaleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    var petAge = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 25)
    }
    
    var paddingLabel = UILabel().then {
        $0.text = "|"
        $0.textColor = .lightGray
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 25)
    }
    
    var hrMeasureView = UIView().then {
        $0.backgroundColor = .hrMesaureColor
        $0.layer.cornerRadius = 40
        $0.layer.maskedCorners = [.layerMinXMinYCorner,
                                  .layerMaxXMinYCorner]
    }
    
    var timeSettingView = UIView().then {
        $0.backgroundColor = .none
    }
    
    var timeSettingLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 25)
        $0.textAlignment = .center
        $0.text = "시간 설정"
    }
    
    let secondSegmentController = UISegmentedControl(items: ["10초", "20초", "30초", "60초"]).then {
        $0.removeBorder()
        $0.selectedSegmentIndex = 0
        $0.layer.borderWidth = 1
        $0.layer.backgroundColor = UIColor.systemGray4.cgColor
    }
    
    var countDownView = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.cornerRadius = 20
        $0.alpha = 0
    }
    
    var countDownLabel = UILabel().then {
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 30)
        $0.textAlignment = .center
    }
    
    let startButton = UIButton().then {
        $0.setTitle("Start", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = Constants.mainColor
        $0.titleLabel?.font = UIFont(name: "Cafe24Syongsyong", size: 50)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.cornerRadius = 20
    }
    
    let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .red
        $0.titleLabel?.font = UIFont(name: "Cafe24Syongsyong", size: 30)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.cornerRadius = 20
        $0.alpha = 0
    }
    
    let measureButton = UIButton().then {
        $0.setTitle("Tap", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .brMeasureButtonColor
        $0.titleLabel?.font = UIFont(name: "Cafe24Syongsyong", size: 60)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.cornerRadius = 20
        $0.alpha = 0
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .hrMeasureBottomViewColor
        
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        let safeGuide = self.safeAreaLayoutGuide
        
        [hrMeasureView,
         petMaleImageView, petName, petAge, paddingLabel, petImageView,
         timeSettingView,               // For time Selecte View -> Change
         countDownView,                 // For Count Down View ---> Change
         cancelButton, startButton, measureButton].forEach {
            addSubview($0)
        }
        
        hrMeasureView.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.centerY)
            $0.leading.trailing.bottom.equalTo(safeGuide)
        }
        
        // MARK: - Pet Profile View
        petImageView.snp.makeConstraints {
            $0.top.equalTo(safeGuide).offset(50)
            $0.leading.equalTo(hrMeasureView.snp.leading).offset(30)
            $0.width.height.equalTo(Constants.viewWidth/4)
        }
        
        petMaleImageView.snp.makeConstraints {
            $0.leading.equalTo(petImageView.snp.trailing).offset(padding*2)
            $0.bottom.equalTo(hrMeasureView.snp.top).offset(-padding)
            $0.width.equalTo(10)
            $0.height.equalTo(30)
        }
        
        petName.snp.makeConstraints {
            $0.leading.equalTo(petMaleImageView.snp.trailing).offset(padding)
            $0.centerY.equalTo(petMaleImageView)
        }
        
        paddingLabel.snp.makeConstraints {
            $0.leading.equalTo(petName.snp.trailing).offset(padding)
            $0.centerY.equalTo(petName)
        }
        
        petAge.snp.makeConstraints {
            $0.leading.equalTo(paddingLabel.snp.trailing).offset(padding)
            $0.centerY.equalTo(paddingLabel)
        }
        
        // MARK: - Time Setting View
        timeSettingView.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.bottom).offset(padding*2)
            $0.leading.equalTo(safeGuide).offset(padding*2)
            $0.trailing.equalTo(safeGuide).offset(-padding*2)
            $0.height.equalTo(80)
        }
        
//        [].forEach {
//            timeSettingView.addSubview($0)
//        }
        addSubview(timeSettingLabel)
        timeSettingLabel.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.bottom).offset(padding*2)
            $0.leading.equalTo(safeGuide).offset(padding*2)
        }
        
        addSubview(secondSegmentController)
        secondSegmentController.snp.makeConstraints {
            $0.top.equalTo(timeSettingLabel.snp.bottom).offset(padding)
            $0.leading.equalTo(safeGuide).offset(padding*2)
            $0.trailing.equalTo(safeGuide).offset(-padding*2)
        }
        
        // MARK: - CountDown View
        
        countDownView.snp.makeConstraints {
            $0.top.equalTo(petImageView.snp.bottom).offset(padding*2)
            $0.leading.equalTo(safeGuide).offset(padding*2)
            $0.trailing.equalTo(safeGuide).offset(-padding*2)
            $0.height.equalTo(80)
        }
        
        countDownView.addSubview(countDownLabel)
        countDownLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        // MARK: - Start Button
        cancelButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(timeSettingView)
            $0.bottom.equalTo(safeGuide).offset(-padding*2-1)
            $0.height.equalTo(cancelButtonHeight)
        }
        
        startButton.snp.makeConstraints {
            $0.top.equalTo(timeSettingView.snp.bottom).offset(padding*2)
            $0.leading.trailing.equalTo(timeSettingView)
            $0.bottom.equalTo(safeGuide).offset(-padding*2)
        }

        measureButton.snp.makeConstraints {
            $0.top.equalTo(timeSettingView.snp.bottom).offset(padding*2)
            $0.leading.trailing.equalTo(timeSettingView)
            $0.bottom.equalTo(safeGuide).offset(-padding*2)
        }
    }
    
    // MARK: - Animation handler
    func readyViewSetupWithAnimation() {
        // Ready UI Appear
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: []) { [unowned self] in
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                startButton.center.x = hrMeasureView.center.x
                startButton.alpha = 1
                countDownView.alpha = 0
                self.cancelButton.alpha = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.5) {
                secondSegmentController.center.x = hrMeasureView.center.x
                secondSegmentController.alpha = 1
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.6) {
                timeSettingLabel.center.x += hrMeasureView.center.x
                timeSettingLabel.alpha = 1
            }
        }
    }
    
    func waitingViewSetupWithAnimation() {
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: []) {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                self.timeSettingLabel.center.x -= Constants.viewWidth
                self.timeSettingLabel.alpha = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.5) {
                self.secondSegmentController.center.x -= Constants.viewWidth
                self.secondSegmentController.alpha = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.6) {
                self.startButton.center.x -= Constants.viewWidth
                self.startButton.alpha = 0
            }
        } completion: { _ in
            
            UIView.animate(withDuration: 0.3) {
                self.countDownView.alpha = 1
                self.cancelButton.alpha = 1
            }
        }
    }
    
    func measureViewSetupWithAnimation() {
        UIView.animate(withDuration: 0.5) {
            
            self.cancelButton.center.x += Constants.viewWidth
            self.cancelButton.alpha = 0
            
        }completion: { _ in
            
            UIView.animate(withDuration: 0.3) {
                
                self.measureButton.alpha = 1
                
            }
        }
        
    }
}
