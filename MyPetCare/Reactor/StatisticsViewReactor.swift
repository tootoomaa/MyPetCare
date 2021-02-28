//
//  StatisticsViewReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/21.
//

import Foundation
import ReactorKit

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
    }
    
    enum Mutation {
        case setSelectedPet(PetObject)                      // 필터 펫 설정
        case setPetObjectList([PetObject])                  // 펫 리스트 저장
        case setChartData([(PetObject, [BrObject])])        // 차트 데이터 저장
        case setDuration(Constants.duration)                // 기간 저장
        
        case setMeasureDataOption([MeasureServiceType])
    }
    
    struct State {
        var selectedPet: PetObject?
        var petList: [PetObject]
        var selectedDuration: Constants.duration
        var charData: [(PetObject, [BrObject])]?
        var filterOption: (petList: PetObject?, measureData: [MeasureServiceType])
    }
    
    var initialState: State
    var provider: ServiceProviderType
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        
        initialState = State(selectedPet: nil,
                             petList: [],
                             selectedDuration: .weak,
                             charData: nil,
                             filterOption: (nil,MeasureServiceType.allCases))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .loadInitialData:
            let list = provider.dataBaseService.loadPetList().toArray()
                        .sorted(by: { $0.createDate! < $1.createDate!})
            
            let brData = list
                .compactMap{$0}
                .map{ pet -> (PetObject, [BrObject]) in
                    let brList = provider.dataBaseService.loadPetBRLog(pet.id!).toArray()
                    let changeData = brList.map{BrObject(brObj: $0)}
                    
                    return (pet, changeData)
                }
            
            return Observable.merge([.just(.setSelectedPet(list.first ?? PetObject())),
                                     .just(.setPetObjectList(list)),
                                     .just(.setChartData(brData))])
            
        case .inputDuration(let duration):
            return .just(.setDuration(duration))
            
        case .setSelectedPet(let index):
            guard !currentState.petList.isEmpty else { return .empty() }            // 비어있는지 확인
            guard currentState.petList.count > index else { return .empty() }       // array index 체크
            
            let petObj = currentState.petList[index]
            return .just(.setSelectedPet(petObj))
            
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
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        
        case .setSelectedPet(let petObj):
            newState.selectedPet = petObj
            newState.filterOption.petList = petObj
        
        case .setPetObjectList(let petList):
            newState.petList = petList
            
        case .setDuration(let duration):
            newState.selectedDuration = duration
            
        case .setChartData(let charData):
            newState.charData = charData
            
        case .setMeasureDataOption(let measureList):
            newState.filterOption.measureData = measureList
        }
        
        return newState
    }
    
}
