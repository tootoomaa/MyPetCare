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
//        case selectPet(Int)
        case selectedIndex(IndexPath)
        case setPetProfileIndex
    }
    
    enum Mutation {
        case setPetObjectList([PetObject])
        case setSelectedPetData(PetObject)
        case setSelectedIndex(IndexPath?)
    }
    
    struct State {
        var petList: [PetObject]?
        var selectedPet: PetObject?
        var selectedIndexPath: IndexPath?
    }
    
    var initialState: State
    let emptyPet = PetObject().then{ $0.uuid = Constants.mainViewPetPlusButtonUUID }
    var provider: ServiceProviderType
    var plusButtonIndex: Int = 0
    
    init(provider: ServiceProviderType) {
        initialState = State(petList: [emptyPet],
                             selectedPet: nil,
                             selectedIndexPath: nil)
        
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        case .loadInitialData:
            var list = provider.dataBaseService.loadPetList().toArray()
            list.append(emptyPet)
            self.plusButtonIndex = list.count - 1
            
            if list.count != 1 {
                return Observable.concat([.just(.setSelectedIndex(IndexPath(item: 0, section: 0))),
                                          .just(.setPetObjectList(list)),
                                          .just(.setSelectedPetData(list.first!))])
            }
            return .just(.setPetObjectList(list))
            
//        case .selectPet(let index):
//            let data = currentState.petList![index]
//            return .just(.setSelectedPetData(data))
//
        case .selectedIndex(let indexPath):
            
            let petObj = currentState.petList![indexPath.row]
            
            return Observable.concat([.just(.setSelectedIndex(indexPath)),
                                      .just(.setSelectedPetData(petObj))])

        case .setPetProfileIndex:
            return .just(.setSelectedIndex(currentState.selectedIndexPath))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        
        case .setPetObjectList(let petList):
            newState.petList = petList
        
        case .setSelectedPetData(let selectedPet):
            newState.selectedPet = selectedPet
            
        case .setSelectedIndex(let indexPath):
            newState.selectedIndexPath = indexPath
            
        }
        
        return newState
    }
    
}
