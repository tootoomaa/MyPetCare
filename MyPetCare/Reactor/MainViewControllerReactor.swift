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
        let petData = Pet(name: "멍멍이",
                          male: .boy,
                          age: 10,
                          weight: 15.0,
                          height: 40.7,
                          profileImage: UIImage(named: "pet1")!.pngData()!,
                          birthday: nil)
        
        let petData2 = Pet(name: "고양이",
                           male: .girl,
                           age: 15,
                           weight: 14.0,
                           height: 40.9,
                           profileImage: UIImage(named: "cat")!.pngData()!,
                           birthday: nil)
        
        initialState = State(petList: [petData, petData2],
                             selectedPet: petData)
        
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
