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
    
    let mainView = PhysicsMeasureView()
    
    let closeNanviButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
    
    // MARK: - Life Cycle
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
        
        navigationController?.configureNavigationBarAppearance(.hrMeasureBottomViewColor)
        navigationItem.title = "체중/키 측정"
        
        closeNanviButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem = closeNanviButton
    }
    
    // MARK: - custom Keyboar & TextField
    private func configureTextFieldDelegate() {
        // 키 입력 텍스트 필트 첫 응답으로 설정
        mainView.heightTextField.becomeFirstResponder()
        
        configureKeyboardToolBar(mainView.heightTextField)
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
        
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let dot = UIBarButtonItem(title: "   ●   ", style: .plain, target: nil, action: nil).then {
            // dot의 특수문자는 "Cafe24Syongsyong" 폰트에 없음
            $0.tintColor = .black
        }
        let next = UIBarButtonItem(title: "Next", style: .plain, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Save", style: .plain, target: nil, action: nil)
        
        [next, done].forEach {
            $0.setTitleTextAttributes(
                [NSAttributedString.Key.foregroundColor: UIColor.black,
                 NSAttributedString.Key.font: UIFont(name: "Cafe24Syongsyong", size: 20)!], for: .normal)
        }
        
        dot.rx.tap
            .subscribe(onNext: {
                textField.text?.append(".")
            }).disposed(by: disposeBag)
        
        // Next Button 선택 시 서로 다른 TextField BecomeFirstResponder 설정
        if textField == mainView.weightTextField {
            next.rx.tap
                .subscribe(onNext: {
                    self.mainView.heightTextField.becomeFirstResponder()
                }).disposed(by: disposeBag)
        } else {
            next.rx.tap
                .subscribe(onNext: {
                    self.mainView.weightTextField.becomeFirstResponder()
                }).disposed(by: disposeBag)
        }
        
        done.rx.tap
            .subscribe(onNext: {
                self.saveAlertController()
            }).disposed(by: disposeBag)
        
        keyboardToolbar.items = [dot, flexBarButton, next, done]
        textField.inputAccessoryView = keyboardToolbar
    }
    
    // MARK: - Reactor bind
    func bind(reactor: BRMeasureViewReactor) {
        
        // 선택된 펫 관련 UI 초기 셋팅
        reactor.state.map{$0.selectedPet}
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] in
                
                mainView.petImageView.image = UIImage(data: $0.image!)
                mainView.petName.text = $0.name
                mainView.petMaleImageView.image = UIImage(named: $0.male ?? "boy" )
                mainView.petAge.text = "\($0.age) yrs"
                
            }).disposed(by: disposeBag)
        
        // weightTextFeild Return 입력 종료 시 edit 종료 및 데이터 저장여부 검증
        mainView.weightTextField.rx.controlEvent(.editingDidEndOnExit)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] in
                saveAlertController()
            }).disposed(by: disposeBag)
    }
    
    private func saveAlertController() {

        guard let reactor = reactor else {fatalError("Check Reactor")}
        
        // 숫자가 아닌 경우 필터링
        guard let height = Double(mainView.heightTextField.text ?? "ErrorValue"),
              let weight = Double(mainView.weightTextField.text ?? "ErrorValue") else {
            let alertC = UIAlertController(title: "입력값 오류", message: "숫자만 입력해주세요. 입력된 값은 초기화 됩니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { [unowned self] _ in
                mainView.heightTextField.text = ""
                mainView.weightTextField.text = ""
            }
            alertC.addAction(okAction)
            self.present(alertC, animated: true, completion: nil)
            return
        }
        
        // 소수점 2자리 까지 변경
        let heightTwoDown = round(height*10)/10
        let weightTwoDown = round(weight*10)/10
        
        let alertC = UIAlertController(title: "저장", message: "변경 사항을 저장하시겠습니까?", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "변경 사항저장", style: .default) { [unowned self]  _ in
            
            reactor.action.onNext(.savePhysicsData(heightTwoDown, weightTwoDown))
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
