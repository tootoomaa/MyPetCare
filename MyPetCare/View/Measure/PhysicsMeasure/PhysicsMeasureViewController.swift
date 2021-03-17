//
//  PhysicsMeasureViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/23.
//

import Foundation
import UIKit
import ReactorKit

class PhysicsMeasureViewController: UIViewController, View {
    
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    var measureType: MeasureServiceType
    
    lazy var mainView = PhysicsMeasureView(type: self.measureType)
    
    let closeNanviButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
    
    let datePicker = UIDatePicker().then {
        $0.datePickerMode = .dateAndTime
        $0.locale = Constants.currentLocale
        $0.maximumDate = Date()
        $0.tintColor = .black
    }
    
    // MARK: - Life Cycle
    init(type: MeasureServiceType) {
        self.measureType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        
        // 저장버튼이 TextFiled Toolbar안에 있기 때문에 키보드가 내려가면 안됨!
        // 별도로 touchBegin EndEditing을 통해서 키보드를 내리지 않음
        configureTextFieldDelegate()
    }
    
    private func configureNavigation() {
        navigationController?.configureNavigation(.hrMeasureBottomViewColor, largeTitle: false)
        navigationItem.title = measureType
                                    .rawValue
                                    .components(separatedBy: .newlines)
                                    .joined(separator: " ")
        
        closeNanviButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem = closeNanviButton
    }
    
    // MARK: - custom Keyboar & TextField
    private func configureTextFieldDelegate() {
        // 키 입력 텍스트 필트 첫 응답으로 설정
        mainView.weightTextField.becomeFirstResponder()
        configureKeyboardToolBar(mainView.weightTextField)
    }
    
    private func configureKeyboardToolBar(_ textField: UITextField) {
        let keyboardToolbar = UIToolbar(
            frame: CGRect(x: 0,
                          y: 0,
                          width: UIScreen.main.bounds.width,
                          height: 44)
        )
        
        keyboardToolbar.sizeToFit()
        keyboardToolbar.barStyle = .default
        
        // padding 버튼
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // 날자 선택 (기본 현재 날짜)
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        
        // . 입력 버튼
        let dot = UIBarButtonItem(title: "   ●   ", style: .plain, target: nil, action: nil).then {
            // dot의 특수문자는 "Cafe24Syongsyong" 폰트에 없음
            $0.tintColor = .black
        }
        
        // 완료 버튼
        let done = UIBarButtonItem(title: "Save", style: .plain, target: nil, action: nil)
        
        [done].forEach {
            $0.setTitleTextAttributes(
                [NSAttributedString.Key.foregroundColor: UIColor.black,
                 NSAttributedString.Key.font: UIFont(name: "Cafe24Syongsyong", size: 20)!], for: .normal)
        }
        
        dot.rx.tap
            .subscribe(onNext: {
                textField.text?.append(".")
            }).disposed(by: disposeBag)
        
        done.rx.tap
            .subscribe(onNext: {
                self.saveAlertController()
            }).disposed(by: disposeBag)
        
        keyboardToolbar.items = measureType == .weight ? [datePickerItem, flexBarButton, dot, done] : [datePickerItem, flexBarButton, done]
        textField.inputAccessoryView = keyboardToolbar
    }
    
    // MARK: - Reactor bind
    func bind(reactor: MeasureViewReactor) {
        
        // 선택된 펫 관련 UI 초기 셋팅
        reactor.state.map{$0.selectedPet}
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] in
                
                guard let petImage = $0.image,
                      let petMale = $0.male else { return }
                
                mainView.petImageView.image = UIImage(data: petImage)
                mainView.petName.text = $0.name
                mainView.petMaleImageView.image = Male(rawValue: petMale)?.getPetMaleImage
                mainView.petAge.text = "\($0.age) yrs"
                
            }).disposed(by: disposeBag)
        
        reactor.state.map{$0.isPetSleep}
            .distinctUntilChanged()
            .map{$0 == true ? "수면 on" : "수면 off" }
            .bind(to: mainView.petStateLabel.rx.text)
            .disposed(by: disposeBag)
        
        // weightTextFeild Return 입력 종료 시 edit 종료 및 데이터 저장여부 검증
        mainView.weightTextField.rx.controlEvent(.editingDidEndOnExit)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] in
                saveAlertController()
            }).disposed(by: disposeBag)
        
        // 사용자 펫 수면 여부 체크 스위치
        mainView.petStateButton.rx.isOn
            .map{Reactor.Action.setPetState($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 수동 입력시 사용자가 변경한 시간 값 설정
        datePicker.rx.value.changed
            .map{Reactor.Action.setMeasureTime($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func saveAlertController() {

        guard let reactor = reactor else {fatalError("Check Reactor")}
        
        // 숫자가 아닌 경우 필터링
        guard let weight = Double(mainView.weightTextField.text ?? "ErrorValue") else {
            let alertC = UIAlertController(title: "입력값 오류", message: "숫자만 입력해주세요. 입력된 값은 초기화 됩니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { [unowned self] _ in
                mainView.weightTextField.text = ""
            }
            alertC.addAction(okAction)
            self.present(alertC, animated: true, completion: nil)
            return
        }
        
        // 소수점 2자리 까지 변경
        let measureData = round(weight*10)/10
        
        let alertC = UIAlertController(title: "저장", message: "변경 사항을 저장하시겠습니까?", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "변경 사항저장", style: .default) { [unowned self]  _ in
            
            if measureType == .weight {
                reactor.action.onNext(.savePhysicsData(measureData))
            } else {
                reactor.action.onNext(.saveBRCount(measureData))
            }
            GlobalState.lastDateUpdate.onNext(Void())
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in }
        
        let destructAction = UIAlertAction(title: "변경 사항 폐기", style: .destructive) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertC.addAction(saveAction)
        alertC.addAction(cancelAction)
        alertC.addAction(destructAction)
        
        self.present(alertC, animated: true, completion: nil)
        
    }
}
