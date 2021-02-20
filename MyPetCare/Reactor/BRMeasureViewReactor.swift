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
        case countNumberSet(Int)
        case plusBRCount
        case resetState
    }
    
    enum Mutation {
        case setMeasureTime(Int)                    // 측정시간 설정 (10~60초)
        case setViewState(BRMeasureViewState)       // View상태에 따라 UI,Animation
        case setCountDownLabelText(String)          // 카운트 다운 텍스트
        case setCountDownNumber(Int)                // 카운트 다운 숫자
        case plusBRCount                            // 호흡수 측정값
        case resetBRCount                           // 호흡수 측정값 초기화
    }
    
    struct State {
        var selectedPet: PetObject                  // 선택된 펫 정보
        var selectedMeatureTime: Int                // 선택된 측정 시간 (10~60초)
        var viewState: BRMeasureViewState?          // View의 상태, 대기/준비/측정
        var countDownLabelText: String?             // Count Down Label
        var countTimeNumber: Int                    // Count Down Time
        var brCount: Int                            // 호흡수 측정값
    }
    
    let waitingForCount: Int = 3
    var initialState: State
    var resultBRCount: Int {
        // 사용자가 선택한 시간에 비례하여 1분 기준으로 리턴
        let multiply = Constants.maxMeasureCount/currentState.selectedMeatureTime
        return currentState.brCount * multiply
    }
    
    init(selectedPat: PetObject) {
        initialState = State(selectedPet: selectedPat,
                             selectedMeatureTime: 0,
                             viewState: nil,
                             countDownLabelText: nil,
                             countTimeNumber: 0,
                             brCount: 0)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        
        case .selectedTime(let time):
            return .just(.setMeasureTime(time))
            
        case .viewStateChange(let measure):
            return .just(.setViewState(measure))
        
        case .countDownLabelText(let text):
            return .just(.setCountDownLabelText(text))
            
        case .countNumberSet(let countNumber):
            return .just(.setCountDownNumber(countNumber))
            
        case .resetState:
            return Observable.merge([.just(.setCountDownLabelText("")),
                                     .just(.setCountDownNumber(0)),
                                     .just(.resetBRCount)])
            
        case .plusBRCount:
            return .just(.plusBRCount)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setMeasureTime(let time):
            newState.selectedMeatureTime = time
            
        case .setViewState(let measure):
            newState.viewState = measure
            
        case .setCountDownLabelText(let text):
            newState.countDownLabelText = text
            
        case .setCountDownNumber(let countTimeNumber):
            newState.countTimeNumber = countTimeNumber
            
        case .plusBRCount:
            newState.brCount += 1
            
        case .resetBRCount:
            newState.brCount = 0
        }
        
        return newState
    }
}
