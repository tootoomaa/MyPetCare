//
//  StatisticsBrData.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/03/02.
//

import Foundation

struct StatisticsBrData {
    
    var id: String!
    var petId: String!
    var createDate: Date!
    var dayIndex: String!
    var resultBR: Int!
    
    var originalBR: Int!
    var userSettingTime: Int!

    init(brObj: BRObject) {
        
        if let id = brObj.id {
            self.id = id
        }
        
        if let petId = brObj.petId {
            self.petId = petId
        }
        
        if let date = brObj.createDate {
            self.createDate = date
            self.dayIndex = TimeUtil().getMonthAndDayString(date: date)
        }
        
        self.resultBR = brObj.resultBR
        self.originalBR = brObj.originalBR
        self.userSettingTime = brObj.userSettingTime
    }
}
