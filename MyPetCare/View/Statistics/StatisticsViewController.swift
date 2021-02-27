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
    
    var charDataFilteringButton = UIButton().then {
        let image = UIImage(systemName: "slider.horizontal.3")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.black)
        
        $0.setImage(image, for: .normal)
    }
    
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
        self.navigationController?.configureNavigationBarAppearance(.white)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "통계"
        
        self.navigationController?.navigationBar.addSubview(charDataFilteringButton)
        charDataFilteringButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-8)
            $0.size.equalTo(30)
        }
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
            .compactMap{$0}
            .withUnretained(self)
            .subscribe(onNext: { owner, data in
//                let newData = data.filter{ $0.0.id == "B296C812-36AC-4869-B20F-B53C9F7C6093" }
//                owner.statisticView.barChartView.setChart(dataPoints: [1,2,3,4,5], values: newData)
            }).disposed(by: disposeBag)
    }
}
