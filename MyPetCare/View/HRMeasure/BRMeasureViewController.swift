//
//  BPMeasureViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import ReactorKit
import UIKit

class BRMeasureViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    let mainView = BRMeasureView()
    
    var watingTimer: Disposable? = nil  // 3초 카운트 다운 Observable Dispose
    var measureTimer: Disposable? = nil // 사용자가 입력한 카운트 다운 Observable Dispose
            
    // MARK: - LifeCycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 타이머 및 reacotr 제거
        self.reactor = nil
        self.watingTimer?.dispose()
        self.measureTimer?.dispose()
    }
    
    private func configureNavigation() {
        
        navigationController?.configureNavigationBarAppearance(.hrMeasureBottomViewColor)
        navigationItem.title = "호흡수 측정"
        
        let closeNanviButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        closeNanviButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem = closeNanviButton
    }
    
    // MARK: - Reactor Binding
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
        
        // Change MainView By viewState
        reactor.state.map{$0.viewState}
            .compactMap{$0}
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] mainViewState in
                switch mainViewState {
                case .ready:        mainView.readyViewSetupWithAnimation()
                case .waiting:      mainView.waitingViewSetupWithAnimation()
                case .measuring:    mainView.measureViewSetupWithAnimation()}
            }).disposed(by: disposeBag)
        
        // Waiting State
        reactor.state.map{$0.viewState}
            .compactMap{$0}
            .distinctUntilChanged()
            .filter{$0 == .waiting}
            .subscribe(onNext: { [unowned self] _ in
                let maxInt = 3
                watingTimer = Observable<Int>
                    .interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
                    .map{maxInt - ($0)}
                    .map{ time in
                        if time == 0 {
                            reactor.action.onNext(.setViewState(.measuring))
                            return "측정 시작!"
                        } else {
                            return "\(time) 초"
                        }
                    }
                    .bind(to: mainView.countDownLabel.rx.text)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
                    watingTimer?.dispose()
                })
            }).disposed(by: disposeBag)
        
        reactor.state.map{$0.viewState}
            .compactMap{$0}
            .distinctUntilChanged()
            .filter{$0 == .measuring}
            .subscribe(onNext: { [unowned self] _ in
                let maxInt = reactor.currentState.selectedMeatureTime
                measureTimer = Observable<Int>
                    .interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
                    .map{maxInt - ($0)}
                    .map{ time in
                        if time == 0 {
                            reactor.action.onNext(.setViewState(.measuring))
                            return "측정 시작!"
                        } else {
                            return "\(time) 초   |   \(reactor.currentState.brCount)회"
                        }
                    }
                    .bind(to: mainView.countDownLabel.rx.text)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
                    watingTimer?.dispose()
                })
            }).disposed(by: disposeBag)
        
        
        // 사용자 시간 선택
        mainView.secondSegmentController.rx.selectedSegmentIndex
            .map{ index -> Int in
                switch index {
                case 0: return 10;
                case 1: return 20;
                case 2: return 30;
                case 3: return 60;
                default: return 60;}
            }.map{Reactor.Action.selectedTime($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.startButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .map{Reactor.Action.setViewState(.waiting)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.cancelButton.rx.tap
            .throttle(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
            .do(onNext:{self.watingTimer?.dispose()})
            .map{Reactor.Action.setViewState(.ready)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.measureButton.rx.tap
            .map{Reactor.Action.plusBRCount}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // MARK: - View State Handler
    private func watingViewState() {
        
    }
}
