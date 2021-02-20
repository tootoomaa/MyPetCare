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
    // 여러번 껏다 켯다 할 경우 이전 타이머가 다른 타이머에 영향을 주지 않도록
    var watingTimers: [Disposable?] = []  // 3초 카운트 다운 Observable Dispose
    var measureTimers: [Disposable?] = [] // 사용자가 입력한 카운트 다운 Observable Dispose
    var waitingTimerIndexForStop: Int = 0
    var measureTimerIndexForStop: Int = 0
            
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
        self.watingTimers.forEach{$0?.dispose()}
        self.measureTimers.forEach{$0?.dispose()}
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
                case .measuring:    mainView.measureViewSetupWithAnimation()
                case .finish:       mainView.finishViewSetupWithAnimation(reactor.resultBRCount)
                }
            }).disposed(by: disposeBag)
        
        reactor.state.map{$0.countDownLabelText}
            .compactMap{$0}
            .distinctUntilChanged()
            .bind(to: mainView.countDownLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.brCount}                   // Measure Button Touch 시 라벨 즉시 갱신
            .distinctUntilChanged()
            .map{"\(reactor.currentState.countTimeNumber) 초       |       \($0)회"}
            .bind(to: mainView.countDownLabel.rx.text)
            .disposed(by: disposeBag)
        
        /////////////////////////////////////////////////////////
        // MARK: - View State (ready->Waiting->Measure->Finish)
        /////////////////////////////////////////////////////////
        // ready View State
        reactor.state.map{$0.viewState}
            .compactMap{$0}
            .distinctUntilChanged()
            .filter{$0 == .ready}
            .subscribe(onNext: { [unowned self] _ in
                
                mainView.readyViewSetupWithAnimation()          // View 상태 원상 복귀
                watingTimers.forEach{$0?.dispose()}             // 타이머 종료
                measureTimers.forEach{$0?.dispose()}
                mainView.countDownLabel.text = ""               // 이전 설정값 제거
                
            }).disposed(by: disposeBag)

        
        // Waiting State
        reactor.state.map{$0.viewState}
            .compactMap{$0}
            .distinctUntilChanged()
            .filter{$0 == .waiting}
            .subscribe(onNext: { [unowned self] _ in
                
                let maxInt = 3
                let watingTimer = Observable<Int>
                    .interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
                    .map{maxInt - ($0)}
                    .map{ time in
                        
                        reactor.action.onNext(.countNumberSet(time))    // 타이머 넘버 저장
                        
                        if time == 0 {
                            reactor.action.onNext(.viewStateChange(.measuring))
                            return "측정 시작!"
                        } else {
                            return "\(time) 초"
                        }
                    }
                    .map{Reactor.Action.countDownLabelText($0)}
                    .bind(to: reactor.action)
                
                watingTimers.append(watingTimer) // 타이머 추가
                
                DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
                    [waitingTimerIndexForStop] in
                    // +1 되기 index를 Capture
                    watingTimers[waitingTimerIndexForStop]?.dispose()
                })
                
                waitingTimerIndexForStop += 1 // 종료할 타이머 index
            }).disposed(by: disposeBag)
        
        
        // Measure View State
        reactor.state.map{$0.viewState}
            .compactMap{$0}
            .distinctUntilChanged()
            .filter{$0 == .measuring}
            .subscribe(onNext: { [unowned self] _ in
                
                let maxInt = reactor.currentState.selectedMeatureTime
                
                let measureTimer = Observable<Int>
                    .interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
                    .map{maxInt - ($0)}
                    .map{ time in
                        
                        reactor.action.onNext(.countNumberSet(time))    // 타이머 넘버 저장
                        
                        if time == -1 {
                            // 이전 타이머 종료
                            guard let measureTimer = measureTimers[measureTimerIndexForStop-1] else {
                                presentErrorAlertController()
                                return "오류 발생"
                            }
                            measureTimer.dispose() // 이전 타이머 종료
                            reactor.action.onNext(.viewStateChange(.finish))
                            return "종료"
                        } else if time == reactor.currentState.selectedMeatureTime {
                            return "측정 시작!"
                        } else {
                            return "\(time) 초       |       \(reactor.currentState.brCount)회"
                        }
                    }
                    .map{Reactor.Action.countDownLabelText($0)}
                    .bind(to: reactor.action)
                
                measureTimers.append(measureTimer)  // MeasureTimer 추가
                measureTimerIndexForStop += 1       // MeasureIndex 추가
                
            }).disposed(by: disposeBag)
        
        // Finish View State
        reactor.state.map{$0.viewState}
            .compactMap{$0}
            .distinctUntilChanged()
            .filter{$0 == .finish}
            .subscribe(onNext: { [unowned self] _ in
                
                watingTimers.forEach{$0?.dispose()}         // 타이머 종료
                measureTimers.forEach{$0?.dispose()}        // 타이머 종료
                mainView.countDownLabel.text = "종료"
                mainView.measureButton.isEnabled = false    // Tap 버튼 비활성화
                
            }).disposed(by: disposeBag)
        
        // MARK: - Button Action
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
            .map{Reactor.Action.viewStateChange(.waiting)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mainView.cancelButton.rx.tap
            .throttle(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
            .do(onNext:{ [unowned self] in
                guard let watingTimers = self.watingTimers[self.waitingTimerIndexForStop-1] else {
                    self.presentErrorAlertController()
                    return
                }
                watingTimers.dispose()
            })
            .map{Reactor.Action.viewStateChange(.ready)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 호흡수 + 1
        mainView.measureButton.rx.tap
            .map{Reactor.Action.plusBRCount}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 측정 안내 버튼
        mainView.howToMeasureButton.rx.tap
            .subscribe(onNext: {
                // 측정 중인 경우 버튼 비활성호
                guard reactor.currentState.viewState != .measuring else { return }
                self.present(
                    BRMeasureHowInfoViewController().then {
                        $0.modalPresentationStyle = .overFullScreen
                        $0.modalTransitionStyle = .crossDissolve
                    },
                    animated: true,
                    completion: nil)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Handler
    func presentErrorAlertController() {
        
        let alertC = UIAlertController(title: "오류 발생",
                                       message: "화면을 종료합니다. 다시 접속해주세요.",
                                       preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertC.addAction(okAction)
        
        present(alertC, animated: true, completion: nil)
        
    }
}
