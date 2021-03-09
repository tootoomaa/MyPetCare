//
//  LastMeasureObject.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/22.
//

import Foundation
import RealmSwift

class LastMeasureObject: Object {
    
    @objc dynamic var petId: String?
    @objc dynamic var resultBR: Int = 0
    @objc dynamic var lastBrCountMeasureTime: Date?
    @objc dynamic var weight: Double = 0.0
    @objc dynamic var lastweightMeasureTime: Date?
    @objc dynamic var petState: PetState.RawValue = "기본"
    
    override static func primaryKey() -> String? {
        return "petId"
    }
    
}
