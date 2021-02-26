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

struct BrObject {
    
    var id: String!
    var petId: String!
    var sectionDate: String!
    var dayDate: String!
    var resultBR: Int!
    
    init(brObj: BRObject) {
        
        if let id = brObj.id {
            self.id = id
        }
        
        if let petId = brObj.petId {
            self.petId = petId
        }
        
        if let date = brObj.createDate {
            self.sectionDate = TimeUtil().getString(date, .yymmdd)
            self.dayDate = TimeUtil().getString(date, .hhmm)
        }
        
        self.resultBR = brObj.resultBR
        
    }
}
