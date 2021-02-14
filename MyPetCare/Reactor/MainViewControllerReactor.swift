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
        case selectedIndexPath(IndexPath)
        case setPetProfileIndex
    
        case deletePet
    }
    
    enum Mutation {
        case setPetObjectList([PetObject])
        case setSelectedPetData(PetObject)
        case setSelectedIndex(IndexPath)
        case reset
    }
    
    struct State {
        var mainFrameTableViewItems = Constants.MainFrameTableViewItem.allCases
        var petList: [PetObject]?
        var selectedPet: PetObject?
        var selectedIndexPath: IndexPath
    }
    
    var initialState: State
    let emptyPet = PetObject().then{ $0.id = Constants.mainViewPetPlusButtonUUID }
    var provider: ServiceProviderType
    var plusButtonIndex: Int = 0
    
    init(provider: ServiceProviderType) {
        initialState = State(petList: nil,
                             selectedPet: nil,
                             selectedIndexPath: IndexPath(row: 0, section: 0))
        
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        case .loadInitialData:
            var list = provider.dataBaseService.loadPetList().toArray().sorted(by: { $0.createDate! < $1.createDate!})
            list.append(emptyPet)
            self.plusButtonIndex = list.count - 1
            
            if list.count != 1 {
                
                let currentIndex = initialState.selectedIndexPath
                let petData = list[currentIndex.row]
                
                return Observable.concat([.just(.setSelectedIndex(currentIndex)),
                                          .just(.setPetObjectList(list)),
                                          .just(.setSelectedPetData(petData))])
            }
            return .just(.setPetObjectList(list))
            
        case .selectedIndexPath(let indexPath):
            
            let petObj = currentState.petList![indexPath.row]
            return Observable.concat([.just(.setSelectedIndex(indexPath)),
                                      .just(.setSelectedPetData(petObj))])

        case .setPetProfileIndex:
            return .just(.setSelectedIndex(currentState.selectedIndexPath))
            
        case .deletePet:
            
            provider.dataBaseService.delete(currentState.selectedPet)
            return .just(.reset)
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
            
        case .reset:
            newState = initialState
        }
        
        return newState
    }
    
}
