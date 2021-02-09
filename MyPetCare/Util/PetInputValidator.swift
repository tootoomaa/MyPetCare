//
//  PetUserInputValidator.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

import Foundation
import UIKit

protocol PetInputValidatorProtocol {
//    func isId(id: String) -> Bool
    func isNameValid(name: String) -> Bool
    func isMaleValid(type: Male) -> Bool
    func isAgeValid(date: Date) -> Bool
//    func isWeightValid(weight: Double) -> Bool
//    func isHeightValid(height: Double) -> Bool
    func isProfileImage(imageData: Data) -> Bool
}

/*
 var id = UUID().uuidString
 var name: String
 var male: Male
 var age: Int?
 var weight: Double?
 var height: Double?
 var profileImage: Data
 var birthday: Date?
 var kind: String?
 var species: String?
 */

class PetInputValidator: PetInputValidatorProtocol {

    func isNameValid(name: String) -> Bool {
        
        return name.count != 0
    }
    
    func isAgeValid(date: Date) -> Bool {
        
        let nowDate = Date().timeIntervalSince1970
        let inputDate = date.timeIntervalSince1970
        
        return nowDate - inputDate > 0
    }
    
    func isMaleValid(type: Male) -> Bool {
        switch type {
        case .boy, .girl:
            return true
        }
    }
    
    func isProfileImage(imageData: Data) -> Bool {
        if UIImage(data: imageData) != nil {
            return true
        }
        return false
    }
}
