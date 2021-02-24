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

enum MainFrameMenuType: CaseIterable {
    case measureServices
    case breathRate
    case physics
}

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
        case setSelectedLastedPerData(LastMeasureObject)
        case reset
    }
    
    struct State {
        var mainFrameTableViewItems = Constants.MainFrameTableViewItem.allCases
        var petList: [PetObject]?
        var selectedPet: PetObject?
        var selectedIndexPath: IndexPath
        var selectedLastedPetData: LastMeasureObject?
    }
    
    var initialState: State
    let emptyPet = PetObject().then{ $0.id = Constants.mainViewPetPlusButtonUUID }
    var provider: ServiceProviderType
    var plusButtonIndex: Int = 0
    
    // MARK: - Init
    init(provider: ServiceProviderType) {
        initialState = State(petList: nil,
                             selectedPet: nil,
                             selectedIndexPath: IndexPath(row: 0, section: 0),
                             selectedLastedPetData: nil)
        
        self.provider = provider
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        case .loadInitialData:
            var list = provider.dataBaseService.loadPetList()
                          .toArray()
                          .sorted(by: { $0.createDate! < $1.createDate!})
            list.append(emptyPet)
            self.plusButtonIndex = list.count - 1
            
            if list.count != 1 {
                
                let currentIndex = initialState.selectedIndexPath
                let petData = list[currentIndex.row]
                
                let lastData = provider.dataBaseService.loadLastData(petData.id!)
                
                return Observable.concat([.just(.setSelectedIndex(currentIndex)),
                                          .just(.setPetObjectList(list)),
                                          .just(.setSelectedPetData(petData)),
                                          .just(.setSelectedLastedPerData(lastData.first!))])
            }
            
            return .just(.setPetObjectList(list))
            
        case .selectedIndexPath(let indexPath):
            
            let petData = currentState.petList![indexPath.row]
            let lastData = provider.dataBaseService.loadLastData(petData.id!)
            
            return Observable.concat([.just(.setSelectedIndex(indexPath)),
                                      .just(.setSelectedPetData(petData)),
                                      .just(.setSelectedLastedPerData(lastData.first!))])

        case .setPetProfileIndex:
            return .just(.setSelectedIndex(currentState.selectedIndexPath))
            
        case .deletePet:
            
            provider.dataBaseService.delete(currentState.selectedPet)
            return .just(.reset)
        }
    }
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        
        case .setPetObjectList(let petList):
            newState.petList = petList
        
        case .setSelectedPetData(let selectedPet):
            newState.selectedPet = selectedPet
            
        case .setSelectedIndex(let indexPath):
            newState.selectedIndexPath = indexPath
            
        case .setSelectedLastedPerData(let data):
            newState.selectedLastedPetData = data
            
        case .reset:
            newState = initialState
        }
        
        return newState
    }
    
    // MARK: - Transfrom
//    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
//        let lastData = provider.dataBaseService.loadLastData(currentState.selectedPet?.id ?? "").toArray()
//        return Observable.merge([mutation,
//                                 GlobalState.savedNewBrData.map{
//                                    .setSelectedLastedPerData(lastData.first!)}])
//    }
}
