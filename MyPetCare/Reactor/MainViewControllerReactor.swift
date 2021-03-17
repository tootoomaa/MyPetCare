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

enum MeasureServiceType: String, CaseIterable {
    case breathRate = "호흡수"
    case sleepBreathRate = "수면호흡수"
    case weight = "체중"
    
    func getColor() -> UIColor {
        switch self {
        case .breathRate:
            return .cViolet
            
        case .sleepBreathRate:
            return .systemTeal
            
        case .weight:
            return .darkGreen
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .breathRate:
            return "호흡수\n측정"
        case .sleepBreathRate:
            return "수면호흡수\n측정"
        case .weight:
            return "몸무게\n측정"
        }
    }
}

enum MainFrameMenuType: String, CaseIterable {
    case measureSV
    case breathRateSV = "호흡수"
    case physicsSV = "체중"
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
        var petList: [PetObject]
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
        initialState = State(petList: [],
                             selectedPet: nil,
                             selectedIndexPath: IndexPath(row: 0, section: 0),
                             selectedLastedPetData: nil)
        
        self.provider = provider
    }
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        case .loadInitialData:
            var list = provider.dataBaseService.loadPetList().toArray()
            ///Data Change ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            provider.dataBaseService.write {
                list.forEach {
                    if $0.male == "boy" || $0.male == "gril" {
                        let maleString = $0.male == "boy" ? "아들" : "딸"
                        $0.male = maleString
                    }
                }
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            list.append(emptyPet)
            self.plusButtonIndex = list.count - 1
            
            if list.count == 1 {                
                return Observable.merge([.just(.setPetObjectList(list)),
                                         .just(.setSelectedLastedPerData(LastMeasureObject()))])
            }
            
            if list.count == 2 {
                
                let currentIndex = initialState.selectedIndexPath
                let petData = list[currentIndex.row]
                
                let lastData = provider.dataBaseService.loadLastData(petData.id!)
                
                return Observable.merge([.just(.setSelectedIndex(currentIndex)),
                                          .just(.setPetObjectList(list)),
                                          .just(.setSelectedPetData(petData)),
                                          .just(.setSelectedLastedPerData(lastData.first!))])
            }
            
            return .just(.setPetObjectList(list))
            
        case .selectedIndexPath(let indexPath):
            guard !currentState.petList.isEmpty else {
                return .just(.setSelectedIndex(initialState.selectedIndexPath))
            }
            let petData = currentState.petList[indexPath.row]
            let lastData = provider.dataBaseService.loadLastData(petData.id!)
            
            return Observable.concat([.just(.setSelectedIndex(indexPath)),
                                      .just(.setSelectedPetData(petData)),
                                      .just(.setSelectedLastedPerData(lastData.first!))])

        case .setPetProfileIndex:
            return .just(.setSelectedIndex(currentState.selectedIndexPath))
            
        case .deletePet:
            
            guard let deletePetId = currentState.selectedPet?.id else { return .empty() }
            
            provider.dataBaseService.deletePetAllData(deletePetId)
            
            GlobalState.MeasureDataUpdateAndChartReload.onNext(Void())
            
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
    func transform(action: Observable<Action>) -> Observable<Action> {
        return Observable.merge([action,
                                 GlobalState.lastDateUpdate
                                    .map{.selectedIndexPath(self.currentState.selectedIndexPath)}])
    }
}
