//
//  SideMenuViewReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/03/12.
//

import Foundation
import ReactorKit

enum SideMenus: String, CaseIterable {
    case backup = "데이터 백업"
    case restore = "데이터 복원"
    case mailContact = "개발자에게 문의"
    case license = "라이센스"
}

class SideMenuViewReactor: Reactor {
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    var initialState: State
    var provider: ServiceProviderType
    
    struct State {
        var sideMenuList: [SideMenus] = SideMenus.allCases
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
