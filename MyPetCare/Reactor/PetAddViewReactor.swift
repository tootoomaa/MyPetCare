//
//  PetAddReactor.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/09.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa
import RealmSwift

class PetAddViewReactor: Reactor {
    
    enum Action {
        case inputPetName(String)
        case inputBirthDay(Date)
        case inputMale(String)
        case inputPetImage(Data)
        
        case savePet
    }
    
    enum Mutation {
        case setPetName(String)
        case setBirthDay(Date)
        case setMale(String)
        case setPetImage(Data)
        
        case saveComplete(Bool)
    }
    
    struct State {
        var petImageData: Data?
        var petName: String
        var birthDay: Date
        var male: String
        var saveComplete: Bool
        var isEnableSaveButton: Bool
        var isEditMode: Bool
    }
    
    let calendar = Calendar.current
    var initialState: State
    var provider: ServiceProviderType
    var beforePetObj: PetObject
    
    init(isEditMode: Bool,
         petData: PetObject,
         provider: ServiceProviderType) {
        
        self.beforePetObj = petData
        initialState = State(petImageData: petData.image,
                             petName: petData.name ?? "",
                             birthDay: petData.date ?? Date(),
                             male: petData.male ?? "boy",
                             saveComplete: false,
                             isEnableSaveButton: false,
                             isEditMode: isEditMode)
        
        self.provider = provider
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .inputPetName(let name):
            return .just(.setPetName(name))
            
        case .inputBirthDay(let date):
            return .just(.setBirthDay(date))
            
        case .inputMale(let male):
            return .just(.setMale(male))
            
        case .inputPetImage(let imageData):
            return .just(.setPetImage(imageData))
            
        case .savePet:
            let group = DispatchGroup.init()
            let queue = DispatchQueue.main
            
            if currentState.isEditMode == false {
                // 신규 Pet 추가
                let petObj = PetObject().then {
                    $0.uuid = UUID().uuidString
                    $0.name = currentState.petName
                    $0.male = currentState.male
                    $0.date = currentState.birthDay
                    $0.age = calendar.component(.year, from: Date()) - calendar.component(.year, from: currentState.birthDay)
                    $0.image = currentState.petImageData
                }
                provider.dataBaseService.add(petObj)
                
            } else {
                // 기존 펫 수정 - uuid 수정하면 안됨
                let newPetData = PetObject().then {
                    $0.uuid = beforePetObj.uuid
                    $0.name = currentState.petName
                    $0.male = currentState.male
                    $0.date = currentState.birthDay
                    $0.age = calendar.component(.year, from: Date()) - calendar.component(.year, from: currentState.birthDay)
                    $0.image = currentState.petImageData
                }
                
                provider.dataBaseService.set(newPetData)
            }
            return .just(.saveComplete(true))
        }
    }
    

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setPetImage(let data):
            newState.petImageData = data
        
        case .setPetName(let name):
            newState.petName = name
            
        case .setBirthDay(let date):
            newState.birthDay = date
            
        case .setMale(let male):
            newState.male = male
            
        case .saveComplete(let isComplete):
            newState.saveComplete = isComplete
        }
        
        newState.isEnableSaveButton =
            !newState.petName.isEmpty &&
            !newState.male.isEmpty &&
            newState.petImageData != nil
        
        return newState
    }
}
