//
//  StatisticsViewReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/21.
//

import Foundation
import ReactorKit

class StatisticsViewReactor: Reactor {
    
    enum Action {
        case loadInitialData
        case inputDuration(Constants.duration)
    }
    
    enum Mutation {
        case setPetObjectList([PetObject])
        case setChartData([(PetObject, [BrObject])])
        case setDuration(Constants.duration)
    }
    
    struct State {
        var petList: [PetObject]?
        var selectedDuration: Constants.duration
        var charData: [(PetObject, [BrObject])]?
    }
    
    var initialState: State
    var provider: ServiceProviderType
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        
        initialState = State(petList: nil,
                             selectedDuration: .weak,
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
            
            return Observable.merge([.just(.setPetObjectList(list)),
                                     .just(.setChartData(brData))])
            
        case .inputDuration(let duration):
            return .just(.setDuration(duration))
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .setPetObjectList(let petList):
            newState.petList = petList
            
        case .setDuration(let duration):
            newState.selectedDuration = duration
            
        case .setChartData(let charData):
            newState.charData = charData
        }
        
        return newState
    }
}
