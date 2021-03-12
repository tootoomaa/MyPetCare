//
//  SideMenuViewReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/03/12.
//

import Foundation
import ReactorKit

class SideMenuViewReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    var initialState: State
    var provider: ServiceProviderType
    
    struct State {
        
    }
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        
        return newState
    }
    
}
