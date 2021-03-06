//
//  StatisticsViewReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/21.
//

import Foundation
import ReactorKit

typealias FilterOptions = (pet: PetObject,
                           measureData: [MeasureServiceType],
                           duration: Constants.duration)

enum StatisticsFilterOptionSection: String, CaseIterable {
    case petList = "펫 리스트"
    case dataType = "선택 정보"
}

class StatisticsViewReactor: Reactor {
    
    enum Action {
        case loadInitialData
        case inputDuration(Constants.duration)
        case setSelectedPet(Int)
        case setMeasureOption(MeasureServiceType)
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
        
        case setNomalBrChartDatas([[StatisticsBrData]])     // [전체] 차트용 보통 호흡 데이터
        case setSleepBrChartDatas([[StatisticsBrData]])     // [전체] 차트용 수면 호흡 데이터
        case setPhyChartDatas([[StatisticPhyData]])         // [전체] 차트용 몸무게 데이터
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
        
        var normalBrChartDatas: [[StatisticsBrData]]
        var sleepBrChartDatas: [[StatisticsBrData]]
        var phyDatas: [[StatisticPhyData]]
    }
    
    var initialState: State
    var provider: ServiceProviderType
    
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
                             
                             normalBrChartDatas: [],
                             sleepBrChartDatas: [],
                             phyDatas: [])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .loadInitialData:
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
                    let brData = provider.dataBaseService
                        .loadPetBRLog(petId)
                        .toArray()
                        .map{StatisticsBrData(brObj: $0)}
                    
                    nomalBrDatas.append(brData.filter{$0.petState == PetState.nomal.rawValue})
                    sleepBrDatas.append(brData.filter{$0.petState == PetState.sleep.rawValue})
                    
                    let fetchedPhyData = provider.dataBaseService
                        .loadPhysicsDataHistory(petId)
                        .map{StatisticPhyData(phyObj: $0)}
                    
                    phyDatas.append(fetchedPhyData)
                }
            
            let pet = petList[currentState.selectIndex]
            let currnetNormalBrData = nomalBrDatas[currentState.selectIndex]
            let currnetSleepData = sleepBrDatas[currentState.selectIndex]
            let curruntPhycisData = phyDatas[currentState.selectIndex]
            
            return Observable.merge([.just(.setSelectedPet(pet)),
                                     .just(.setPetObjectList(petList)),
                                     .just(.setNomalBrChartData(currnetNormalBrData)),
                                     .just(.setSleepBrChartData(currnetSleepData)),
                                     .just(.setPhyChartData(curruntPhycisData)),
                                     .just(.setNomalBrChartDatas(nomalBrDatas)),
                                     .just(.setSleepBrChartDatas(sleepBrDatas)),
                                     .just(.setPhyChartDatas(phyDatas)),
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
            
            return Observable.merge([.just(.setSelectedPet(petObj)),
                                     .just(.setSelectPetIndex(index)),
                                     .just(.setNomalBrChartData(currnetNormalBrData)),
                                     .just(.setSleepBrChartData(currnetSleepData)),
                                     .just(.setPhyChartData(curruntPhycisData))])
            
        case .setMeasureOption(let measureServiceType):
            var list = currentState.filterOption.measureData
            
            if list.contains(measureServiceType) {
                if let index = list.firstIndex(of: measureServiceType) {
                    print(index)
                    list.remove(at: index)
                }
            } else {
                list.append(measureServiceType)
            }
            
            return .just(.setMeasureDataOption(list))
            
        case .reloadChart:
            return .just(.reloadChartData)
        }
    }
    
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
            
        case .setNomalBrChartDatas(let brChartData):
            newState.normalBrChartDatas = brChartData
            
        case .setSleepBrChartDatas(let sleepData):
            newState.sleepBrChartDatas = sleepData
            
        case .setPhyChartDatas(let phyChartData):
            newState.phyDatas = phyChartData
            
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
}


