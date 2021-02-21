//
//  BPObject.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import RealmSwift

class BRObject: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var petId: String?
    @objc dynamic var createDate: Date?
    @objc dynamic var originalBR: Int = 0
    @objc dynamic var resultBR: Int = 0
    @objc dynamic var userSettingTime: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
