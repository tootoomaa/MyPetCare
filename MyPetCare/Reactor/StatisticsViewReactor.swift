//
//  StatisticsViewReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/21.
//

import Foundation
import ReactorKit
import RxDataSources

typealias FilterOptions = (pet: PetObject,
                           measureData: [MeasureServiceType],
                           duration: Constants.duration)

enum StatisticsFilterOptionSection: String, CaseIterable {
    case petList = "펫 리스트"
    case dataType = "선택 정보"
}

struct StatisticDetailDataTableViewSection {
    let items: [ChartDetailValue]
    let header: String
    
    init(items: [ChartDetailValue], header: String) {
        self.items = items
        self.header = header
    }
}

extension StatisticDetailDataTableViewSection: SectionModelType {
    typealias Item = ChartDetailValue
    
    init(original: Self, items: [Self.Item]) {
        self = original
    }
}

struct ChartDetailValue: Equatable, CustomStringConvertible {
    var type: MeasureServiceType
    var createDate: Date
    var value: Double
    var brOptionValue: (userMeasuerTiem: Int, value: Int)?
    
    var description: String {
        return "\(TimeUtil().getString(createDate, .callHistoryCellStyle))"
    }
    
    static func == (lhs: ChartDetailValue, rhs: ChartDetailValue) -> Bool {
        return lhs.createDate != rhs.createDate
            || lhs.value != rhs.value
            || lhs.type != rhs.type
    }
}

class StatisticsViewReactor: Reactor {
    
    enum Action {
        case loadInitialData
        case inputDuration(Constants.duration)
        case setSelectedPet(Int)
        case setMeasureOption(MeasureServiceType)
        case reloadDetailTableViewData
        case reloadChart
    }
    
    enum Mutation {
        case resetState
        case setSelectPetIndex(Int)                         // 펫 선택 인덱스
        case setPetObjectList([PetObject])                  // 펫 리스트 저장
        case setSelectedPet(PetObject)                      // [필터] 펫 설정
        case setMeasureDataOption([MeasureServiceType])     // [필터] 데이터 선택
        case setDuration(Constants.duration)                // [필터] 기간 저장
        
        case setNomalBrChartData([StatisticsBrData])        // [선택] 차트용 보통 호흡 데이터
        case setSleepBrChartData([StatisticsBrData])        // [선택] 차트용 수면 호흡 데이터
        case setPhyChartData([StatisticPhyData])            // [선택] 차트용 몸무게 데이터
        case setAllDetailDate([ChartDetailValue])           // [선택] 펫 측정 상세 데이터 for TableView
        case setSectionData([StatisticDetailDataTableViewSection]?)         // 필터 된 데이터
        
        case setNomalBrChartDatas([[StatisticsBrData]])     // [전체] 차트용 보통 호흡 데이터
        case setSleepBrChartDatas([[StatisticsBrData]])     // [전체] 차트용 수면 호흡 데이터
        case setPhyChartDatas([[StatisticPhyData]])         // [전체] 차트용 몸무게 데이터
        case setAllDetailDatas([[ChartDetailValue]])        // [전체] 펫별 측정 상세 데이터 for TableView
        case setSectionDatas([[StatisticDetailDataTableViewSection]])
        
        case reloadChartData                                // When chartReload Measure Data change
    }
    
    struct State {
        var selectIndex: Int
        var selectedPet: PetObject?
        var petList: [PetObject]
        var filterOption: FilterOptions
        var reloadChartTrigger: Bool
        
        var normalBrChartData: [StatisticsBrData]
        var sleepBrChartData: [StatisticsBrData]
        var phyData: [StatisticPhyData]
        var allDetailData: [ChartDetailValue]
        
        var normalBrChartDatas: [[StatisticsBrData]]
        var sleepBrChartDatas: [[StatisticsBrData]]
        var phyDatas: [[StatisticPhyData]]
        var allDetailDatas: [[ChartDetailValue]]
        
        var sectionTableViewData: [StatisticDetailDataTableViewSection]?
        var sectionTableViewDatas: [[StatisticDetailDataTableViewSection]]
    }
    
    var initialState: State
    var provider: ServiceProviderType
    
    // MARK: - Init
    init(provider: ServiceProviderType) {
        self.provider = provider
        
        initialState = State(selectIndex: 0,
                             selectedPet: nil,
                             petList: [],
                             filterOption: (PetObject.empty,
                                            MeasureServiceType.allCases,
                                            .weak),
                             reloadChartTrigger: false,
                             
                             normalBrChartData: [],
                             sleepBrChartData: [],
                             phyData: [],
                             allDetailData: [],
                             
                             normalBrChartDatas: [],
                             sleepBrChartDatas: [],
                             phyDatas: [],
                             allDetailDatas: [],
                             
                             sectionTableViewData: nil,
                             sectionTableViewDatas: [])
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .loadInitialData:
            var sectionDataLists: [[StatisticDetailDataTableViewSection]] = []
            var allDetailDatas: [[ChartDetailValue]] = []
            var nomalBrDatas: [[StatisticsBrData]] = []
            var sleepBrDatas: [[StatisticsBrData]] = []
            var phyDatas: [[StatisticPhyData]] = []
            
            let petList = provider.dataBaseService.loadPetList().toArray()
                        .sorted(by: { $0.createDate! < $1.createDate!})
            
            guard !petList.isEmpty else {
                return .just(.resetState)
            }
            
            petList.compactMap{$0.id}
                .forEach { petId in
                    var currentPetAllData: [ChartDetailValue] = []
                    let brData = provider.dataBaseService
                        .loadPetBRLog(petId)
                        .toArray()
                    
                    /// 호흡 데이터 생성 ------------------------------------------
                    // 차트 데이터 생성
                    let brDataForChart = brData.map{StatisticsBrData(brObj: $0)}
                    nomalBrDatas.append(brDataForChart.filter{$0.measureType == .breathRate})
                    sleepBrDatas.append(brDataForChart.filter{$0.measureType == .sleepBreathRate})
                    
                    // 차트 디테일 데이터 생성 (상세 정보)
                    let brDataForDetail = brData.map{
                        ChartDetailValue(
                            type: MeasureServiceType(rawValue: $0.measureType ?? "") ?? .breathRate,
                            createDate: $0.createDate!,
                            value: Double($0.resultBR),
                            brOptionValue: ($0.originalBR, $0.userSettingTime)
                        )
                    }
                    
                    currentPetAllData.append(contentsOf: brDataForDetail)
                    /// 체중 데이터 생성 ------------------------------------------
                    // 차트 데이터 생성
                    let phyData = provider.dataBaseService
                        .loadPhysicsDataHistory(petId)
                    
                    let weightDataForChart = phyData.map{StatisticPhyData(phyObj: $0)}
                    phyDatas.append(weightDataForChart)
                    
                    // 차트 디테일 데이터 생성 (상세 정보)
                    let weightDataForDetail = phyData.map{
                        ChartDetailValue(
                            type: .weight,
                            createDate: $0.createDate!,
                            value: $0.weight,
                            brOptionValue: nil)
                    }
                    currentPetAllData.append(contentsOf: weightDataForDetail)
                    currentPetAllData.sort {$0.createDate > $1.createDate}
                    allDetailDatas.append(currentPetAllData)
                }
            
            let pet = petList[currentState.selectIndex]
            let currnetNormalBrData = nomalBrDatas[currentState.selectIndex]
            let currnetSleepData = sleepBrDatas[currentState.selectIndex]
            let curruntPhycisData = phyDatas[currentState.selectIndex]
            let currentAllDetailData = allDetailDatas[currentState.selectIndex]
            
            let list = TimeUtil().getMonthAndDayString(.month, .mmdd).reversed()
            // 테이블 뷰 RxDataSource 생성
            allDetailDatas.forEach { detailDataList in
                
                var sectionDataList: [StatisticDetailDataTableViewSection] = []
                
                list.forEach { dayIndex in
                    
                    let tempList = detailDataList.filter {
                        TimeUtil().getMonthAndDayString(date: $0.createDate) == dayIndex
                    }
                    
                    guard let firstData = tempList.first else { return }
                    let sectionHeader = TimeUtil().getString(firstData.createDate, .yymmdd)
                    sectionDataList.append(StatisticDetailDataTableViewSection(items: tempList,
                                                                               header: sectionHeader))
                }
                
                sectionDataLists.append(sectionDataList)
            }
            
            let curruntSectionData = sectionDataLists[currentState.selectIndex]
            
            return Observable.merge([.just(.setSelectedPet(pet)),
                                     .just(.setPetObjectList(petList)),
                                     .just(.setNomalBrChartData(currnetNormalBrData)),
                                     .just(.setSleepBrChartData(currnetSleepData)),
                                     .just(.setPhyChartData(curruntPhycisData)),
                                     .just(.setNomalBrChartDatas(nomalBrDatas)),
                                     .just(.setSleepBrChartDatas(sleepBrDatas)),
                                     .just(.setPhyChartDatas(phyDatas)),
                                     .just(.setAllDetailDate(currentAllDetailData)),
                                     .just(.setAllDetailDatas(allDetailDatas)),
                                     .just(.setSectionData(curruntSectionData)),
                                     .just(.setSectionDatas(sectionDataLists)),
                                     .just(.reloadChartData)])
            
        case .inputDuration(let duration):
            return .just(.setDuration(duration))
            
        case .setSelectedPet(let index):
            guard !currentState.petList.isEmpty else { return .empty() }        // 비어있는지 확인
            guard currentState.petList.count > index else { return .empty() }   // array index 체크
            
            let petObj = currentState.petList[index]
            
            let currnetNormalBrData = currentState.normalBrChartDatas[index]
            let currnetSleepData = currentState.sleepBrChartDatas[index]
            let curruntPhycisData = currentState.phyDatas[index]
            let curruntSectiondData = currentState.sectionTableViewDatas[index]
            
            // 각각의 데이터에서 현제 선택된 필터 값들만 추출
            curruntSectiondData.forEach {
                // 필터에 맞는 값 추출
                _ = $0.items.filter {
                    return currentState.filterOption.measureData.contains($0.type)
                }
            }
            
            return Observable.merge([.just(.setSelectedPet(petObj)),
                                     .just(.setSelectPetIndex(index)),
                                     .just(.setNomalBrChartData(currnetNormalBrData)),
                                     .just(.setSleepBrChartData(currnetSleepData)),
                                     .just(.setPhyChartData(curruntPhycisData)),
                                     .just(.setSectionData(curruntSectiondData.count == 0 ? nil : curruntSectiondData))])
            
        case .setMeasureOption(let measureServiceType):
            var list = currentState.filterOption.measureData
            
            if list.contains(measureServiceType) {
                if let index = list.firstIndex(of: measureServiceType) {
                    list.remove(at: index)
                }
            } else {
                list.append(measureServiceType)
            }
            return .just(.setMeasureDataOption(list))
            
        case .reloadDetailTableViewData:
            let index = currentState.selectIndex
            let curruntSectiondData = currentState.sectionTableViewDatas[index]
            let measureType = currentState.filterOption.measureData
            let duration = currentState.filterOption.duration
            let dayString = TimeUtil().getMonthAndDayString(duration, .yymmdd)
            
            let newdata = curruntSectiondData.map { value -> StatisticDetailDataTableViewSection? in
                
                // 기간 설정에 따른 값 필터링
                if !dayString.contains(value.header) { return nil }
                
                // 사용자가 필터한 데이터 여부 체크
                let list = value.items.filter{ return measureType.contains($0.type) }
                // 데이터가 빈경우 nil
                guard !list.isEmpty else { return nil }
                
                return StatisticDetailDataTableViewSection(items: list, header: value.header)
            }.compactMap{$0}
            
            return .just(.setSectionData(newdata))
            
        case .reloadChart:
            return .just(.reloadChartData)
        }
    }
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .resetState:
            newState = initialState
        
        case .setSelectPetIndex(let index):
            newState.selectIndex = index
        
        case .setPetObjectList(let petList):
            newState.petList = petList
        
        case .setSelectedPet(let petObj):
            newState.selectedPet = petObj
            newState.filterOption.pet = petObj
            
        case .setDuration(let duration):
            newState.filterOption.duration = duration
            
        case .setMeasureDataOption(let measureList):
            newState.filterOption.measureData = measureList
            
        case .setNomalBrChartData(let list):
            newState.normalBrChartData = list
            
        case .setSleepBrChartData(let list):
            newState.sleepBrChartData = list
            
        case .setPhyChartData(let list):
            newState.phyData = list
            
        case .setAllDetailDate(let list):
            newState.allDetailData = list
            
        case .setNomalBrChartDatas(let brChartData):
            newState.normalBrChartDatas = brChartData
            
        case .setSleepBrChartDatas(let sleepData):
            newState.sleepBrChartDatas = sleepData
            
        case .setPhyChartDatas(let phyChartData):
            newState.phyDatas = phyChartData
            
        case .setAllDetailDatas(let alldata):
            newState.allDetailDatas = alldata
            
        case .setSectionData(let list):
            newState.sectionTableViewData = list
            
        case .setSectionDatas(let lists):
            newState.sectionTableViewDatas = lists
            
        case .reloadChartData:
            newState.reloadChartTrigger.toggle()
        }
        
        return newState
    }

    // MARK: - Transform
    func transform(action: Observable<Action>) -> Observable<Action> {
        return Observable.merge([action,
                                 GlobalState.MeasureDataUpdateAndChartReload
                                    .map{ _ in .loadInitialData}])
    }
    
    // MARK: - Data Handler
    
}


