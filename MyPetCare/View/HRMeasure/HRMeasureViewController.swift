//
//  BPMeasureViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import ReactorKit
import UIKit

class HRMeasureViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    let mainView = HReasureView()
    
    
    // MARK: - LifeCycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
    }
    
    private func configureNavigation() {
        
        navigationController?.configureNavigationBarAppearance(.hrMesaureColor)
        navigationItem.title = "심박수 측정"
        
        let closeNanviButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        closeNanviButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem = closeNanviButton
    }
    
    // MARK: - Reactor Binding
    func bind(reactor: HRMeasureViewReactor) {
        
        // 선택된 펫 관련 UI 초기 셋팅
        reactor.state.map{$0.selectedPet}
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] in
                
                mainView.petImageView.image = UIImage(data: $0.image!)
                mainView.petName.text = $0.name
                mainView.petMaleImageView.image = UIImage(named: $0.male ?? "boy" )
                mainView.petAge.text = "\($0.age) yrs"
                
            }).disposed(by: disposeBag)
        
        // 사용자 시간 선택
        mainView.secondSegmentController.rx.selectedSegmentIndex
            .map{ index -> Int in
                switch index {
                case 0: return 10;
                case 1: return 20;
                case 2: return 30;
                case 3: return 60;
                default: return 60;
                }
            }.map{Reactor.Action.selectedTime($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
