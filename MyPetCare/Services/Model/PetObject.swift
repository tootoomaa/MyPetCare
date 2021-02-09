//
//  Pet.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/03.
//

import Foundation
import UIKit
import RealmSwift

class PetObject: Object {
    
    @objc dynamic var uuid: String?
    @objc dynamic var name: String?
    @objc dynamic var male: Male.RawValue?
    @objc dynamic var age: Int = 0
    @objc dynamic var date: Date?
    @objc dynamic var image: Data?
    @objc dynamic var weight: Double = 0.0
    @objc dynamic var height: Double = 0.0
}

extension PetObject {
    static var empty: PetObject {
        return PetObject().then { $0.uuid = nil }
    }
}

enum Male: String {
    case boy
    case girl
}

//struct Pet: Equatable {
//
//    var id = UUID().uuidString
//    var name: String
//    var male: Male
//    var age: Int?
//    var weight: Double?
//    var height: Double?
//    var profileImage: Data
//    var birthday: Date?
//    var kind: String?
//    var species: String?
//
//    init(name: String,
//         male: Male,
//         age: Int = 0,
//         weight: Double = 0.0,
//         height: Double = 0.0,
//         profileImage: Data,
//         birthday: Date?) {
//        self.name = name
//        self.male = male
//        self.age = age
//        self.weight = weight
//        self.height = height
//        self.profileImage = profileImage
//        self.birthday = birthday
//    }
//
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    static func empty() -> Pet {
//        return Pet(name: "EmptyPet", male: .boy, profileImage: (UIImage(systemName: "plus")?.pngData())!, birthday: nil)
//    }
//}

