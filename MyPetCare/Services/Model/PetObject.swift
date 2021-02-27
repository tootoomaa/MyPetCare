//
//  Pet.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/03.
//

import Foundation
import UIKit
import RealmSwift

enum PetType: String, CaseIterable {
    case dog = "강아지"
    case cat = "고양이"
}

class PetObject: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var createDate: Date?
    @objc dynamic var name: String?
    @objc dynamic var male: Male.RawValue?
    @objc dynamic var age: Int = 0
    @objc dynamic var birthDate: Date?
    @objc dynamic var image: Data?
    @objc dynamic var weight: Double = 0.0
    @objc dynamic var petType: PetType.RawValue?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension PetObject {
    static var empty: PetObject {
        return PetObject().then { $0.id = nil }
    }
}

enum Male: String {
    case boy
    case girl
}
