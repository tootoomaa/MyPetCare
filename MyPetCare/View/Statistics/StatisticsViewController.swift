//
//  StatisticsViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

import Foundation
import UIKit
import ReactorKit

class StatisticsViewController: UIViewController, View {
    
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    let statisticView = StatisticView()
    
    // MARK: - Life Cycle
    override func loadView() {
        view = statisticView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.rx.viewWillAppear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.configureNavigation()
            }).disposed(by: disposeBag)
        
        configureNavigation()
    }
    
    private func configureNavigation() {
        navigationController?.configureNavigationBarAppearance(.white)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "통계"
    }
    
    // MARK: - ReactorKit Binder
    func bind(reactor: StatisticsViewReactor) {
        
        self.rx.viewDidLoad
            .map{Reactor.Action.loadInitialData}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 기간 선택 segment 설정
        statisticView.barChartView
            .durationSegmentController.rx.value.changed
            .distinctUntilChanged()
            .map{ index -> Constants.duration in
                switch index {
                case 0: return Constants.duration.weak
                case 1: return Constants.duration.month
                default: return Constants.duration.weak }}
            .map{Reactor.Action.inputDuration($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.charData}
            .subscribe(onNext: {
                print($0)
            }).disposed(by: disposeBag)
        
            
    }
}
