//
//  BPObject.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import RealmSwift

class BPObject: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var petId: String?
    @objc dynamic var createDate: Date?
    @objc dynamic var userSettingTime: Int = 0
    @objc dynamic var bloodPressure: Double = 0
//    @objc dynamic var
        
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
