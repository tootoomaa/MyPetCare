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

class MeasureViewReactor: Reactor {
    
    enum Action {
        // BRMeasureViewController
        case selectedTime(Int)
        case viewStateChange(BRMeasureViewState)
        case countDownLabelText(String)
        case countNumberSet(Int)
        case plusBRCount
        case resetState
        case saveBRResult
        // PhysicsMeasureViewContoller
        case savePhysicsData(Double, Double)
        // MeasureDetailViewController
        case loadBrCountData
        case loadPhysicsData
    }
    
    enum Mutation {
        // BRMeasureViewController
        case setMeasureTime(Int)                    // 측정시간 설정 (10~60초)
        case setViewState(BRMeasureViewState)       // View상태에 따라 UI,Animation
        case setCountDownLabelText(String?)         // 카운트 다운 텍스트
        case setCountDownNumber(Int)                // 카운트 다운 숫자
        case plusBRCount                            // 호흡수 측정값
        case resetBRCount                           // 호흡수 측정값 초기화
        case saveCompleteAndDismiss                 // 저장 완료 및 dismiss
        // MeasureDetailVC
        case setBrCountLiat([BRObject]?)
        case setPhysicsList([PhysicsObject]?)
    }
    
    struct State {
        // BRMeasureViewController
        var selectedPet: PetObject                  // 선택된 펫 정보
        var selectedMeatureTime: Int                // 선택된 측정 시간 (10~60초)
        var viewState: BRMeasureViewState?          // View의 상태, 대기/준비/측정
        var countDownLabelText: String?             // Count Down Label
        var countTimeNumber: Int                    // Count Down Time
        var brCount: Int                            // 호흡수 측정값
        var saveCompleteAndDismiss: Bool?           // 저장 완료 및 dismiss
        // MeasureDetailVC
        var brCountHistory: [BRObject]?
        var physicsHistory: [PhysicsObject]?
    }
    
    var provider: ServiceProviderType
    var selectedPet: PetObject
    let waitingForCount: Int = 3
    var initialState: State
    var petId: String {
        return selectedPet.id ?? ""
    }
    
    // For Result
    var resultBRCount: Int {
        // 사용자가 선택한 시간에 비례하여 1분 기준으로 리턴
        let multiply = Constants.maxMeasureCount/currentState.selectedMeatureTime
        return currentState.brCount * multiply
    }
    
    // For Result
    var resultUserMeasureData: (Int, Int) {
        return (currentState.brCount, currentState.selectedMeatureTime)
    }
    
    init(selectedPat: PetObject, provider: ServiceProviderType) {
        self.provider = provider
        self.selectedPet = selectedPat
        initialState = State(selectedPet: selectedPat,
                             selectedMeatureTime: 0,
                             viewState: nil,
                             countDownLabelText: nil,
                             countTimeNumber: 0,
                             brCount: 0,
                             saveCompleteAndDismiss: nil)
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
            return Observable.merge([.just(.setCountDownLabelText(nil)),
                                     .just(.setCountDownNumber(0)),
                                     .just(.resetBRCount)])
        case .plusBRCount:
            return .just(.plusBRCount)
            
        case .saveBRResult:                           // 호흡수 측정 데이터 저장
            // Save Measured Breath Rate
            let bpObject = BRObject().then {
                $0.id = UUID().uuidString
                $0.petId = currentState.selectedPet.id
                $0.createDate = Date()
                $0.originalBR = currentState.brCount
                $0.resultBR = resultBRCount
                $0.userSettingTime = currentState.selectedMeatureTime
            }
            provider.dataBaseService.add(bpObject)
            
            // Last Data Save
            let lastData = provider.dataBaseService
                            .loadLastData(currentState.selectedPet.id!)
                            .toArray()
            provider.dataBaseService.write {
                lastData.first!.resultBR = resultBRCount
            }
            return .just(.saveCompleteAndDismiss)
            
        case .savePhysicsData(let height, let weight): // 키 몸무게 저장 로직
            
            // DB 저장
            let petObj = currentState.selectedPet
            provider.dataBaseService.write {
                petObj.height = height
                petObj.weight = weight
            }
            
            // 최근 데이터 저장
            let lastData = provider.dataBaseService.loadLastData(petObj.id!).toArray().first
            provider.dataBaseService.write {
                lastData?.height = height
                lastData?.weight = weight
            }
            
            let newPhysicObj = PhysicsObject().then {
                $0.id = UUID().uuidString
                $0.petId = currentState.selectedPet.id
                $0.createDate = Date()
                $0.height = height
                $0.weight = weight
            }
            provider.dataBaseService.add(newPhysicObj)
            
            return .empty()
            
        case .loadBrCountData:
            let list = provider.dataBaseService.loadPetBRLog(petId).toArray()
            return .just(.setBrCountLiat(list))
            
        case .loadPhysicsData:
            let list = provider.dataBaseService.loadPhysicsDataHistory(petId).toArray()
            return .just(.setPhysicsList(list))
            
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
            
        case .saveCompleteAndDismiss:
            newState.saveCompleteAndDismiss = true
            
        case .setBrCountLiat(let list):
            newState.brCountHistory = list
            
        case .setPhysicsList(let list):
            newState.physicsHistory = list
            
        }
        
        return newState
    }
}
