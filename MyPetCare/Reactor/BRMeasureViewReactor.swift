//
//  BPMeasureViewReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import ReactorKit

enum BRMeasureViewState {
    case ready
    case waiting
    case measuring
    case finish
}

class BRMeasureViewReactor: Reactor {
    
    enum Action {
        case selectedTime(Int)
        case viewStateChange(BRMeasureViewState)
        case countDownLabelText(String)
        case plusBRCount
    }
    
    enum Mutation {
        case setTime(Int)
        case setViewState(BRMeasureViewState)
        case setCountDownLabelText(String)
        case plusBRCount
    }
    
    struct State {
        var selectedPet: PetObject              // 선택된 펫 정보
        var selectedMeatureTime: Int            // 선택된 측정 시간
        var viewState: BRMeasureViewState?      // View의 상태, 대기/준비/측정
        var countDownLabelText: String?          // Count Down Label
        var brCount: Int
    }
    
    let readyForCount: Int = 3
    var initialState: State
    
    init(selectedPat: PetObject) {
        initialState = State(selectedPet: selectedPat,
                             selectedMeatureTime: 0,
                             viewState: nil,
                             countDownLabelText: nil,
                             brCount: 0)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        
        case .selectedTime(let time):
            return .just(.setTime(time))
            
        case .viewStateChange(let measure):
            return .just(.setViewState(measure))
        
        case .countDownLabelText(let text):
            return .just(.setCountDownLabelText(text))
            
        case .plusBRCount:
            return .just(.plusBRCount)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTime(let time):
            newState.selectedMeatureTime = time
            
        case .setViewState(let measure):
            newState.viewState = measure
            
        case .setCountDownLabelText(let text):
            newState.countDownLabelText = text
            
        case .plusBRCount:
            newState.brCount += 1
        }
        
        return newState
    }
}
