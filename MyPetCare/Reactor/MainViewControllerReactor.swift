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
        case selectPet(Int)
    }
    
    enum Mutation {
        case setSelectedPetData(Pet)
    }
    
    struct State {
        var petList: [Pet]?
        var selectedPet: Pet?
    }
    
    var initialState: State
    var provider: ServiceProviderType
    
    init(provider: ServiceProviderType) {
        
        let emptyPet = Pet().then{
            $0.name = nil
        }
        print(emptyPet)
        initialState = State(petList: [emptyPet],
                             selectedPet: nil)
        
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectPet(let index):
            
            return .just(.setSelectedPetData((currentState.petList![index])))
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        
        case .setSelectedPetData(let selectedPet):
            newState.selectedPet = selectedPet
            
        }
        
        return newState
    }
    
}
