//
//  BPMeasureViewReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import ReactorKit

class HRMeasureViewReactor: Reactor {
    
    enum Action {
        case selectedTime(Int)
    }
    
    enum Mutation {
        case setTime(Int)
    }
    
    struct State {
        var selectedPet: PetObject
        var selectedTime: Int
    }
    
    var initialState: State
    
    init(selectedPat: PetObject) {
        initialState = State(selectedPet: selectedPat,
                             selectedTime: 0)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        
        case .selectedTime(let time):
            return .just(.setTime(time))
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTime(let time):
            newState.selectedTime = time
        }
        
        return newState
    }
}
