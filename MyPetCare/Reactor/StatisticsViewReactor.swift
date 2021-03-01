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
    }
    
    enum Mutation {
        case setPetObjectList([PetObject])                  // 펫 리스트 저장
        case setSelectedPet(PetObject)                      // [필터] 펫 설정
        case setMeasureDataOption([MeasureServiceType])     // [필터] 데이터 선택
        case setDuration(Constants.duration)                // [필터] 기간 저장
        case setChartData([(PetObject, [BrObject])])        // 차트 데이터 저장
    }
    
    struct State {
        var selectedPet: PetObject?
        var petList: [PetObject]
        var filterOption: FilterOptions
        var charData: [(PetObject, [BrObject])]?
    }
    
    var initialState: State
    var provider: ServiceProviderType
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        
        initialState = State(selectedPet: nil,
                             petList: [],
                             filterOption: (PetObject.empty, MeasureServiceType.allCases,
                                            .weak),
                             charData: nil)
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
        
        case .setPetObjectList(let petList):
            newState.petList = petList
        
        case .setSelectedPet(let petObj):
            newState.selectedPet = petObj
            newState.filterOption.pet = petObj
            
        case .setDuration(let duration):
            newState.filterOption.duration = duration
            
        case .setMeasureDataOption(let measureList):
            newState.filterOption.measureData = measureList
            
        case .setChartData(let charData):
            newState.charData = charData
        }
        
        return newState
    }
    
}
