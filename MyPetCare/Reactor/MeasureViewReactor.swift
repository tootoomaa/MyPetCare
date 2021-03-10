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
        case setPetState(Bool)
        case saveBRResult
        // PhysicsMeasureViewContoller
        case savePhysicsData(Double)                // 몸무게 저장
        case saveBRCount(Double)                    // 측정값
        case setMeasureTime(Date)
        // MeasureDetailViewController
        case loadBrCountData
        case loadPhysicsData
        case removeMeasureData(Int, MainFrameMenuType)
    }
    
    enum Mutation {
        // BRMeasureViewController
        case setMeasureTime(Int)                    // 측정시간 설정 (10~60초)
        case setViewState(BRMeasureViewState)       // View상태에 따라 UI,Animation
        case setCountDownLabelText(String?)         // 카운트 다운 텍스트
        case setCountDownNumber(Int)                // 카운트 다운 숫자
        case plusBRCount                            // 호흡수 측정값
        case setPetState(Bool)                      // 펫 상태값, 기본 <-> 수면
        case setUserSelectedMeasureTime(Date)       // 수동 측정 시각 입력
        case resetBRCount                           // 호흡수 측정값 초기화
        case saveCompleteAndDismiss                 // 저장 완료 및 dismiss
        // MeasureDetailVC
        case setBrCountLiat([BRObject])
        case setPhysicsList([PhysicsObject])
    }
    
    struct State {
        // BRMeasureViewController
        var selectedPet: PetObject                  // 선택된 펫 정보
        var selectedMeatureTime: Int                // 선택된 측정 시간 (10~60초)
        var viewState: BRMeasureViewState?          // View의 상태, 대기/준비/측정
        var countDownLabelText: String?             // Count Down Label
        var countTimeNumber: Int                    // Count Down Time
        var brCount: Int                            // 호흡수 측정값
        var isPetSleep: Bool                          // 펫 상태 (휴식, 수면)
        var userSelectedMeasureTime: Date           // 사용자가 수동으로 입력한 시간
        var saveCompleteAndDismiss: Bool?           // 저장 완료 및 dismiss
        // MeasureDetailVC
        var brCountHistory: [BRObject]
        var physicsHistory: [PhysicsObject]
    }
    
    var provider: ServiceProviderType
    var selectedPet: PetObject
    let waitingForCount: Int = 3
    var initialState: State
    var selectedPetId: String {
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
    
    var petState: Bool {
        return currentState.isPetSleep
    }
    
    var currentPetState: String {
        return currentState.isPetSleep
            ? MeasureServiceType.sleepBreathRate.rawValue
            : MeasureServiceType.breathRate.rawValue
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
                             isPetSleep: false,
                             userSelectedMeasureTime: Date(),
                             saveCompleteAndDismiss: nil,
                             brCountHistory: [],
                             physicsHistory: [])
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
                $0.measureType = currentPetState
            }
            
            provider.dataBaseService.add(bpObject)
            
            // Last Data Save
            self.lastDataSave(petId: selectedPetId,
                              resultBr: Double(resultBRCount),
                              lastBrCountMeasureTime: Date(),
                              measureType: currentState.isPetSleep)
            
            GlobalState.MeasureDataUpdateAndChartReload.onNext(Void())     // 데이터 갱신 업데이트
            return .just(.saveCompleteAndDismiss)
            
        case .setPetState(let state):
            return .just(.setPetState(state))
            
        case .savePhysicsData(let weight): // 몸무게 저장 로직
            
            // 메인 펫 프로필 DB 저장
            let petObj = currentState.selectedPet
            provider.dataBaseService.write {
                petObj.weight = weight
            }
            
            // 최근 데이터 저장
            self.lastDataSave(petId: selectedPetId,
                              weight: weight,
                              lastWeightMeasureTime: currentState.userSelectedMeasureTime)
            
            // 신규 측정 데이터 저장
            let newPhysicObj = PhysicsObject().then {
                $0.id = UUID().uuidString
                $0.petId = currentState.selectedPet.id
                $0.createDate = currentState.userSelectedMeasureTime
                $0.weight = weight
            }
            
            provider.dataBaseService.add(newPhysicObj)
            GlobalState.MeasureDataUpdateAndChartReload.onNext(Void())                    // 데이터 갱신 업데이트
            return .empty()
            
        // 펫 수동 측정 데이터 저장 로직 1분 기준
        case .saveBRCount(let brCount):
            
            // Save Measured Breath Rate
            let bpObject = BRObject().then {
                $0.id = UUID().uuidString
                $0.petId = currentState.selectedPet.id
                $0.createDate = currentState.userSelectedMeasureTime
                $0.originalBR = Int(brCount/60)
                $0.resultBR = Int(brCount)
                $0.userSettingTime = 60
                $0.measureType = currentPetState
            }
            provider.dataBaseService.add(bpObject)

            // Last Data Save
            self.lastDataSave(petId: selectedPetId,
                              resultBr: brCount,
                              lastBrCountMeasureTime: currentState.userSelectedMeasureTime,
                              measureType: currentState.isPetSleep)
            
            GlobalState.MeasureDataUpdateAndChartReload.onNext(Void())
            return .empty()
            
        case .setMeasureTime(let date):
            return .just(.setUserSelectedMeasureTime(date))
            
        case .loadBrCountData:
            let list = provider.dataBaseService.laodBrCountDataHistory(selectedPetId)
            return .just(.setBrCountLiat(list))
            
        case .loadPhysicsData:
            let list = provider.dataBaseService.loadPhysicsDataHistory(selectedPetId)
            return .just(.setPhysicsList(list))
            
        case .removeMeasureData(let index, let type):
            
            switch type {
            case .breathRateSV:
                var list = currentState.brCountHistory
                let deleteObj = list.remove(at: index)
                provider.dataBaseService.delete(deleteObj)
                
                if index == 0 { // 최근 데이터 삭제한 경우 메인 화면의 최근 호흡수 수정
                    let obj = provider.dataBaseService.loadLastData(selectedPetId).first
                    provider.dataBaseService.write {
                        obj?.resultBR = list.first?.resultBR ?? 0
                    }
                    GlobalState.lastDateUpdate.onNext(Void())              // 최근 측정 데이터 갱신
                }
                
                GlobalState.MeasureDataUpdateAndChartReload.onNext(Void()) // 데이터 갱신 업데이트
                return .just(.setBrCountLiat(list))
                
            case .physicsSV:
                var list = currentState.physicsHistory
                let deleteObj = list.remove(at: index)
                provider.dataBaseService.delete(deleteObj)
                
                if list.isEmpty { // 마지막 데이터 삭제 일때 0으로 수정
                    if let petObject = provider.dataBaseService.loadPet(petId: selectedPetId).first {
                        provider.dataBaseService.write {
                            petObject.weight = 0
                        }
                    }
                }
                
                if index == 0 { // 최근 데이터 삭제한 경우 메인 화면의 최근 체중 수정
                    let obj = provider.dataBaseService.loadLastData(selectedPetId).first
                    provider.dataBaseService.write {
                        obj?.weight = list.first?.weight ?? 0
                    }
                    GlobalState.lastDateUpdate.onNext(Void())                      // 최근 측정 데이터 갱신
                }
                
                GlobalState.MeasureDataUpdateAndChartReload.onNext(Void())         // 데이터 갱신 업데이트
                return .just(.setPhysicsList(list))
                
            case .measureSV:
                return .empty()
            }
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
            
        case .setPetState(let state):
            newState.isPetSleep = state
            
        case .setUserSelectedMeasureTime(let date):
            newState.userSelectedMeasureTime = date
            
        case .saveCompleteAndDismiss:
            newState.saveCompleteAndDismiss = true
            
        case .setBrCountLiat(let list):
            newState.brCountHistory = list
            
        case .setPhysicsList(let list):
            newState.physicsHistory = list
            
        }
        
        return newState
    }
    
    // MARK: - Last Data Hanlder
    /// 최근 데이터 저장
    private func lastDataSave(petId: String,
                              resultBr: Double? = nil,
                              lastBrCountMeasureTime: Date? = nil,
                              weight: Double? = nil,
                              lastWeightMeasureTime: Date? = nil,
                              measureType: Bool? = false
    ) {
        
        guard let lastData = provider.dataBaseService.loadLastData(petId).toArray().first else {
            print("Empty")
            return
        }
        
        // 호흡수 저장
        if let resultBr = resultBr,
           let measureType = measureType,
           let lastBrCountMeasureTime = lastBrCountMeasureTime{
            provider.dataBaseService.write {
                lastData.resultBR = Int(resultBr)
                lastData.measureType = currentPetState
                lastData.lastBrCountMeasureTime = lastBrCountMeasureTime
            }
        }
        
        // 체중 데이터 저장
        if let newWeight = weight,
           let lastWeightMeasureTiem = lastWeightMeasureTime {
            provider.dataBaseService.write {
                lastData.weight = newWeight
                lastData.lastweightMeasureTime = lastWeightMeasureTiem
            }
        }
    }
}
