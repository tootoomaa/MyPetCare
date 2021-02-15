//
//  BPMeasureViewReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import ReactorKit

class BPMeasureViewReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var selectedPet: PetObject
    }
    
    var initialState: State
    
    init(selectedPat: PetObject) {
        initialState = State(selectedPet: selectedPat)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
