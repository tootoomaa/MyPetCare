//
//  MainVCReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/03.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class MainViewControllerReactor: Reactor {
    
    enum Action {
        case loadInitialData
        case selectPet(Int)
    }
    
    enum Mutation {
        case setPetObjectList([PetObject])
        case setSelectedPetData(PetObject)
    }
    
    struct State {
        var petList: [PetObject]?
        var selectedPet: PetObject?
    }
    
    var initialState: State
    let emptyPet = PetObject().then{ $0.name = nil }
    var provider: ServiceProviderType
    
    init(provider: ServiceProviderType) {
        
        
        initialState = State(petList: [emptyPet],
                             selectedPet: nil)
        
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        case .loadInitialData:
            
            var list = provider.dataBaseService.loadPetList().toArray()
            list.append(emptyPet)
            return .just(.setPetObjectList(list))
            
        case .selectPet(let index):
            
            return .just(.setSelectedPetData((currentState.petList![index])))
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        
        case .setSelectedPetData(let selectedPet):
            newState.selectedPet = selectedPet
            
        case .setPetObjectList(let petList):
            newState.petList = petList
        }
        
        return newState
    }
    
}
