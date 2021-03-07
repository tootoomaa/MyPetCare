//
//  StatisticsViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

import Foundation
import UIKit
import ReactorKit
import RxGesture

class StatisticsViewController: UIViewController, View {
    
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    var allDetailData: [ChartDetailValue] = []
    
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
        
        configureStatisticViewMainFrameTableView()
        
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
    
    private func configureStatisticViewMainFrameTableView() {
        statisticView.mainFrameTable.dataSource = self
        statisticView.mainFrameTable.delegate = self
        statisticView.mainFrameTable
            .register(MeasureDetailTableViewCell.self,
                      forCellReuseIdentifier: MeasureDetailTableViewCell.identifier)
    }
    
    // MARK: - ReactorKit Binder
    func bind(reactor: StatisticsViewReactor) {
        
        self.rx.viewDidLoad
            .map{Reactor.Action.loadInitialData}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.selectedPet}
            .distinctUntilChanged()
            .do(onNext: {
                if $0 == nil {
                    self.selectedPetName.text = ""
                    self.selectedPetMaleImageView.image = UIImage()
                    self.selectPetImageView.image = UIImage()
                }
            })
            .compactMap{$0}
            .subscribe(onNext: {
                self.selectedPetName.text = $0.name
                self.selectPetImageView.image = UIImage(data: $0.image!)
                self.selectedPetMaleImageView.image = Male(rawValue: $0.male!)?.getPetMaleImage
            }).disposed(by: disposeBag)
        
        reactor.state.map{$0.petList}
            .map{!$0.isEmpty}
            .bind(to: statisticView.petListEmptyView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.allDetailData}
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { owner, list in
                owner.allDetailData = list
                owner.statisticView.mainFrameTable.reloadData()
            }).disposed(by: disposeBag)
        
        // 필터 옵션 변경에 따른 차트 재설정
        reactor.state.map{$0.filterOption}
            .observe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged { (filter1, filter2) -> Bool in
                guard filter1.pet == filter2.pet else { return false }
                guard filter1.measureData == filter2.measureData else { return false }
                guard filter1.duration == filter2.duration else { return false }
                return true}
            .map{ _ in Reactor.Action.reloadChart}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 데이터 변경에 따른 차트 재설정
        reactor.state.map{$0.reloadChartTrigger}
            .observe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                
                guard !reactor.currentState.petList.isEmpty else { return }
                owner.configureChart(reactor.currentState.filterOption,
                                     reactor.currentState.normalBrChartData,
                                     reactor.currentState.sleepBrChartData,
                                     reactor.currentState.phyData)
                
            }).disposed(by: disposeBag)
        
        // 데이터 변경에 따른 차트 재설정
        reactor.state.map{$0.selectIndex}
            .observe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                
                guard !reactor.currentState.petList.isEmpty else { return }
                owner.configureChart(reactor.currentState.filterOption,
                                     reactor.currentState.normalBrChartData,
                                     reactor.currentState.sleepBrChartData,
                                     reactor.currentState.phyData)
                
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
        
        // 필터 버튼 선택
        charDataFilteringButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.statisticView.filterOptionShowAnimation()
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
                            
                            // 펫 데이터가 있으면 첫 펫은 무조건 선택 되도록
                            if reactor.currentState.selectedPet == petData {
                                cell.isSelected = true
                                let initialIndexPath = IndexPath(item: 0, section: 0)
                                petListCollectionView.selectItem(at: initialIndexPath, animated: true, scrollPosition: .left)
                            }
                            
                        }.disposed(by: disposeBag)
                    
                    [petListCollectionView].forEach {
                        cell.contentView.addSubview($0)
                        $0.snp.makeConstraints {
                            $0.top.equalToSuperview().offset(10)
                            $0.leading.equalToSuperview().offset(20)
                            $0.trailing.equalToSuperview().inset(20)
                            $0.bottom.equalToSuperview().offset(-10)
                            $0.height.equalTo(50)
                        }
                    }
                    
                case .dataType:
                    
                    Observable.just(MeasureServiceType.allCases)
                        .bind(to: measureDataTypeListCollectionView.rx
                                .items(cellIdentifier: "Cell")) { [unowned self] row, type, cell in
                            
                            let button = UIButton().then {
                                cell.contentView.addSubview($0)
                                $0.setTitle(type.getTitle(), for: .normal)
                                $0.setTitleColor(.black, for: .normal)
                                $0.setTitleColor(.white, for: .selected)
                                $0.setBackgroundColor(color: .white, forState: .normal)
                                $0.setBackgroundColor(color: type.getColor(),
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
                    
                    [measureDataTypeListCollectionView].forEach {
                        cell.contentView.addSubview($0)
                        $0.snp.makeConstraints {
                            $0.top.equalToSuperview().offset(10)
                            $0.leading.equalToSuperview().offset(20)
                            $0.trailing.equalToSuperview().inset(20)
                            $0.bottom.equalToSuperview().offset(-10)
                            $0.height.equalTo(50)
                        }
                    }
                }
                
            }.disposed(by: disposeBag)
        
        petListCollectionView.rx.itemSelected
            .map{$0.row}
            .map{Reactor.Action.setSelectedPet($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        statisticView.dismiaView.rx.tapGesture()
            .skip(1)                             // 최초 1회 bind 시 실행 차단
            .withUnretained(self)
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { owner, _ in
                owner.statisticView.filterOptionShowAnimation()
            }).disposed(by: disposeBag)
        
    }
    
    // MARK: - Chart handler
    private func configureChart(_ filterOption: FilterOptions,
                                _ normalBrData: [StatisticsBrData],
                                _ sleepBrData: [StatisticsBrData],
                                _ phyData: [StatisticPhyData]) {
        
        var resultNormalBrList: [Int] = []               // 휴식 BR 이력 저장
        var resultSleepBrList: [Int] = []                // 수면 Br 이력 저장
        var resultPhyList: [Double] = []                 // Phy 이력 저장
        
        // 당일을 기준으로 [1달/7일]데이터 추출
        let indexlist = TimeUtil().getMonthAndDayString(type: filterOption.duration)
        
        // 데이터 생성 부분
        indexlist.forEach { index in
            /// 일반 호흡수 데이터 추출 --------------------------------------- -------------------------------------
            let normalBrCount = normalBrData                                    // 호흡수 측정 갯수
                .filter{$0.dayIndex == index}
                .count
            let normalBrSum = normalBrData                                      // BR 총합
                .filter{$0.dayIndex == index}
                .map{$0.resultBR}
                .reduce(0, +)
            // 일 평균 값 추출, 0 나누기 방지
            resultNormalBrList.append(normalBrCount == 0 ? 0 : normalBrSum/normalBrCount)
            
            /// 수면 호흡수 데이터 추출 --------------------------------------- -------------------------------------
            let sleepBrCount = sleepBrData                                    // 호흡수 측정 갯수
                .filter{$0.dayIndex == index}
                .count
            let sleepBrSum = sleepBrData                                      // BR 총합
                .filter{$0.dayIndex == index}
                .map{$0.resultBR}
                .reduce(0, +)
            // 일 평균 값 추출, 0 나누기 방지
            resultSleepBrList.append(sleepBrCount == 0 ? 0 : sleepBrSum/sleepBrCount)
            
            /// Physics 데이터 추출 --------------------------------------- ------------------------------------
            let phyCount = phyData
                .filter{$0.dayIndex == index}
                .count
            let phySum = phyData
                .filter{$0.dayIndex == index}
                .map{$0.weight}
                .reduce(0.0, +)
            resultPhyList.append(phyCount == 0 ? 0 : phySum/Double(phyCount))
        }
        
        statisticView.statisticChartView.setChart(filterOption: filterOption,
                                                  resultNormalBrList: resultNormalBrList,
                                                  resultSleepBrList: resultSleepBrList,
                                                  resultPhyList: resultPhyList)
    }
}

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allDetailData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MeasureDetailTableViewCell.identifier,
                                                 for: indexPath) as! MeasureDetailTableViewCell
        
        let data = allDetailData[indexPath.row]
        cell.configureChartDetailData(data: data)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
