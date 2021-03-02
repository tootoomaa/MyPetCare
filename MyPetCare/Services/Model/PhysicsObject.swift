//
//  PhysicsObject.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/24.
//

import Foundation
import RealmSwift

class PhysicsObject: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var petId: String?
    @objc dynamic var createDate: Date?
    @objc dynamic var weight: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
