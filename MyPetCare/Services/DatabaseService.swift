//
//  DatabaseService.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

import Foundation
import RealmSwift

protocol DatabaseServiceType {
    var database: Realm { get }
}

class DatabaseService: BaseService, DatabaseServiceType {
    
    var database = try! Realm()
    
}
