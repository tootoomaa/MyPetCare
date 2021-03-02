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
    
    let selectedPetName = UILabel().then {
        $0.font = UIFont(name: "Cafe24Syongsyong", size: 15)
    }
    
    let selectPetImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    var selectedPetMaleImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
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
        
        [charDataFilteringButton, selectedPetMaleImageView, selectedPetName, selectPetImageView].forEach {
            self.navigationController?.navigationBar.addSubview($0)
        }
        
        charDataFilteringButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-8)
            $0.size.equalTo(30)
        }
        
        selectPetImageView.snp.makeConstraints {
            $0.centerY.equalTo(charDataFilteringButton)
            $0.trailing.equalTo(charDataFilteringButton.snp.leading).offset(-10)
            $0.width.height.equalTo(24)
        }
        
        selectedPetName.snp.makeConstraints {
            $0.trailing.equalTo(selectPetImageView.snp.leading).offset(-3)
            $0.centerY.equalTo(selectPetImageView)
        }
        
        selectedPetMaleImageView.snp.makeConstraints {
            $0.trailing.equalTo(selectedPetName.snp.leading).offset(-5)
            $0.centerY.equalTo(selectPetImageView)
            $0.height.equalTo(12)
            $0.width.equalTo(6)
        }
    }
    
    // MARK: - ReactorKit Binder
    func bind(reactor: StatisticsViewReactor) {
        
        self.rx.viewDidLoad
            .map{Reactor.Action.loadInitialData}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map{$0.selectedPet}
            .distinctUntilChanged()
            .compactMap{$0}
            .subscribe(onNext: {
                self.selectedPetName.text = $0.name
                self.selectPetImageView.image = UIImage(data: $0.image ?? UIImage().pngData()!)
                self.selectedPetMaleImageView.image = Male(rawValue: $0.male!)?.getPetMaleImage
            }).disposed(by: disposeBag)
        
        reactor.state.map{$0.filterOption}
            .distinctUntilChanged { (filter1, filter2) -> Bool in
                guard filter1.pet == filter2.pet else { return false }
                guard filter1.measureData == filter2.measureData else { return false }
                guard filter1.duration == filter2.duration else { return false }
                return true
            }.subscribe(onNext: { [unowned self] filterOption in
                
                guard let currentPetId = reactor.currentState.selectedPet?.id else { return }
                
                let brData = reactor.provider.dataBaseService
                                    .loadPetBRLog(currentPetId)
                                    .toArray()
                                    .map{StatisticsBrData(brObj: $0)}
                
                let phyData = reactor.provider.dataBaseService
                                     .loadPhysicsDataHistory(currentPetId)
                                     .map{StatisticPhyData(phyObj: $0)}
                
                statisticView.statisticChartView.setChart(filterOption: filterOption,
                                                          brData: brData,
                                                          phyData: phyData)
            }).disposed(by: disposeBag)
        
        reactor.state.map{$0.reloadChartTrigger}
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] _ in
                
                guard let currentPetId = reactor.currentState.selectedPet?.id else { return }
                let filterOption = reactor.currentState.filterOption
                
                let brData = reactor.provider.dataBaseService
                                    .loadPetBRLog(currentPetId)
                                    .toArray()
                                    .map{StatisticsBrData(brObj: $0)}
                
                let phyData = reactor.provider.dataBaseService
                                     .loadPhysicsDataHistory(currentPetId)
                                     .map{StatisticPhyData(phyObj: $0)}
                
                statisticView.statisticChartView.setChart(filterOption: filterOption,
                                                          brData: brData,
                                                          phyData: phyData)
            }).disposed(by: disposeBag)
        
        // 기간 선택 segment 설정
        statisticView.statisticChartView
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
                                
//                                case breathRate = "호흡수\n측정"
//                                case weight = "체중\n측정"
                                $0.setBackgroundColor(color: type == .breathRate ? .cViolet : .deepGreen,
                                                      forState: .selected)
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
