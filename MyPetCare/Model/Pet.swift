//
//  Pet.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/03.
//

import Foundation

enum Male: String {
    case boy
    case girl
}

struct Pet: Equatable {
    
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
    
    init(name: String,
         male: Male,
         age: Int = 0,
         weight: Double = 0.0,
         height: Double = 0.0,
         profileImage: Data,
         birthday: Date?) {
        self.name = name
        self.male = male
        self.age = age
        self.weight = weight
        self.height = height
        self.profileImage = profileImage
        self.birthday = birthday
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
