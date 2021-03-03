//
//  StatictisPhyData.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/03/02.
//

import Foundation

struct StatisticPhyData {
    
    var id: String!
    var petId: String!
    var createDate: Date!
    var dayIndex: String!
    var weight: Double!
    
    init(phyObj: PhysicsObject) {
        
        if let id = phyObj.id {
            self.id = id
        }
        
        if let petId = phyObj.petId {
            self.petId = petId
        }
        
        if let date = phyObj.createDate {
            self.createDate = date
            self.dayIndex = TimeUtil().getMonthAndDayString(date: date)
        }
        
        self.weight = phyObj.weight
    }
}
