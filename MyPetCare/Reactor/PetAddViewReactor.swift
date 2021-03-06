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
        case inputSpecies(String)
        case inputPetImage(Data)
        
        case savePet
    }
    
    enum Mutation {
        case setPetName(String)
        case setBirthDay(Date)
        case setMale(String)
        case setPetImage(Data)
        case setSpecies(String)
        
        case isComplete(Bool)
    }
    
    struct State {
        var petImageData: Data?
        var petName: String
        var birthDay: Date
        var male: String
        var species: String
        var isComplete: Bool
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
        print(petData)
        initialState = State(petImageData: petData.image,
                             petName: petData.name ?? "",
                             birthDay: petData.birthDate ?? Date(),
                             male: petData.male ?? Male.boy.rawValue,
                             species: petData.species ?? SpeciesType.dog.rawValue,
                             isComplete: false,
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
            
        case .inputSpecies(let species):
            return .just(.setSpecies(species))
            
        case .inputPetImage(let imageData):
            return .just(.setPetImage(imageData))
            
        case .savePet:
            if currentState.isEditMode == false {
                // 신규 Pet 추가
                let petObj = PetObject().then {
                    $0.id = UUID().uuidString
                    $0.createDate = Date()
                    $0.name = currentState.petName
                    $0.male = currentState.male
                    $0.species = currentState.species
                    $0.birthDate = currentState.birthDay
                    $0.age = calendar.component(.year, from: Date()) - calendar.component(.year, from: currentState.birthDay)
                    $0.image = currentState.petImageData
                }
                provider.dataBaseService.add(petObj)
                // 최근 데이터 저장
                let lastMeasureObj = LastMeasureObject().then {
                    $0.petId = petObj.id
                }
                provider.dataBaseService.add(lastMeasureObj)
                GlobalState.MeasureDataUpdateAndChartReload.onNext(Void())
            } else {
                // 기존 펫 수정 - uuid, createTime 수정하면 안됨
                provider.dataBaseService.write {
                    beforePetObj.name = currentState.petName
                    beforePetObj.male = currentState.male
                    beforePetObj.species = currentState.species
                    beforePetObj.birthDate = currentState.birthDay
                    beforePetObj.age = calendar.component(.year, from: Date()) - calendar.component(.year, from: currentState.birthDay)
                    beforePetObj.image = currentState.petImageData
                }
            }
            return .just(.isComplete(true))
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
            
        case .setSpecies(let sepices):
            newState.species = sepices
            
        case .isComplete(let isComplete):
            newState.isComplete = isComplete
            
        }
        
        newState.isEnableSaveButton =
            !newState.petName.isEmpty &&
            !newState.male.isEmpty &&
            newState.petImageData != nil
        
        return newState
    }
}
