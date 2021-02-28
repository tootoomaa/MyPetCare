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
    
    let petListLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: 50, height: 50)
        $0.minimumLineSpacing = 10
    }
    
    lazy var petListCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: petListLayout
    ).then {
        $0.register(PetOptionCollectionViewCell.self,
                    forCellWithReuseIdentifier: PetOptionCollectionViewCell.identifier)
        $0.backgroundColor = .white
        $0.allowsSelection = true
        $0.allowsMultipleSelection = false
    }
    
    let measureListLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: 75, height: 40)
        $0.minimumLineSpacing = 10
        $0.minimumInteritemSpacing = 10
    }
    
    lazy var measureDataTypeListCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: measureListLayout
    ).then {
        $0.register(UICollectionViewCell.self,
                    forCellWithReuseIdentifier: "Cell")
        $0.backgroundColor = .white
        $0.allowsSelection = true
        $0.allowsMultipleSelection = true
        $0.delaysContentTouches = false
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
        
        reactor.state.map{$0.charData}
            .compactMap{$0}
            .withUnretained(self)
            .subscribe(onNext: { owner, data in
//                let newData = data.filter{ $0.0.id == "B296C812-36AC-4869-B20F-B53C9F7C6093" }
//                owner.statisticView.barChartView.setChart(dataPoints: [1,2,3,4,5], values: newData)
            }).disposed(by: disposeBag)
//        
//        reactor.state.map{$0.filterOption.measureData}
//            .distinctUntilChanged()
//            .subscribe(onNext: {
//                print($0)
//            }).disposed(by: disposeBag)
        
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
        
        charDataFilteringButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                
                let beforeAlpa = owner.statisticView.filterOptionTableView.alpha
                
                UIView.animate(withDuration: 0.5) {
                    owner.statisticView.filterOptionTableView.alpha = beforeAlpa == 1 ? 0 : 1
                }
                
                
            }).disposed(by: disposeBag)
        
        // MARK: - Filter Option TableView
        Observable.just(StatisticsFilterOptionSection.allCases)
            .distinctUntilChanged()
            .bind(to: statisticView.filterOptionTableView.rx
                    .items(cellIdentifier: "Cell")) { [unowned self] row, type, cell in
                
                cell.selectionStyle = .none
                
                switch type {
                case .petList:
                                            
                    reactor.state.map{$0.petList}
                        .distinctUntilChanged()
                        .compactMap{$0}
                        .debug()
                        .bind(to: petListCollectionView.rx
                                .items(cellIdentifier: PetOptionCollectionViewCell.identifier,
                                       cellType: PetOptionCollectionViewCell.self)) { row, petData , cell in
                            cell.configureCell(petObj: petData)
                            
                            // 첫 셀은 무조건 선택 되도록
                            if reactor.currentState.selectedPet == petData {
                                cell.isSelected = true
                                let initialIndexPath = IndexPath(item: 0, section: 0)
                                petListCollectionView.selectItem(at: initialIndexPath, animated: true, scrollPosition: .left)
                            }
                            
                        }.disposed(by: disposeBag)
                    
                    cell.contentView.addSubview(petListCollectionView)
                    petListCollectionView.snp.makeConstraints {
                        $0.top.equalToSuperview().offset(10)
                        $0.leading.equalToSuperview().offset(20)
                        $0.trailing.equalToSuperview().inset(20)
                        $0.bottom.equalToSuperview().offset(-10)
                        $0.height.equalTo(50)
                    }
                    
                case .dataType:
                    
                    Observable.just(MeasureServiceType.allCases)
                        .bind(to: measureDataTypeListCollectionView.rx
                                .items(cellIdentifier: "Cell")) { [unowned self] row, type, cell in
                            
                            let button = UIButton().then {
                                cell.contentView.addSubview($0)
                                $0.setTitle(type.rawValue, for: .normal)
                                $0.setTitleColor(.black, for: .normal)
                                $0.setTitleColor(.white, for: .selected)
                                $0.setBackgroundColor(color: .white, forState: .normal)
                                $0.setBackgroundColor(color: .cViolet, forState: .selected)
                                $0.titleLabel?.font = .dynamicFont(name: "Cafe24Syongsyong", size: 18)
                                $0.isSelected = true
                                $0.addCornerRadius(20)
                                $0.addBorder(.black, 1)
                                $0.snp.makeConstraints {
                                    $0.edges.equalToSuperview()
                                }
                            }
                            // 필터 메뉴 선택
                            button.rx.tap
                                .subscribe(onNext: { [unowned button, type] in
                                    button.isSelected.toggle()
                                    reactor.action.onNext(.setMeasureOption(type))
                                }).disposed(by: disposeBag)
                            
                        }.disposed(by: disposeBag)
                    
                    cell.contentView.addSubview(measureDataTypeListCollectionView)
                    measureDataTypeListCollectionView.snp.makeConstraints {
                        $0.top.equalToSuperview().offset(10)
                        $0.leading.equalToSuperview().offset(20)
                        $0.trailing.equalToSuperview().inset(20)
                        $0.bottom.equalToSuperview().offset(-10)
                        $0.height.equalTo(40)
                    }
                }
                
            }.disposed(by: disposeBag)
        
        petListCollectionView.rx.itemSelected
            .map{$0.row}
            .map{Reactor.Action.setSelectedPet($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
