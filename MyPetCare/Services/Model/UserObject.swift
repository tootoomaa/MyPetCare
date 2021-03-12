//
//  UserObject.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/03/12.
//

import Foundation
import RealmSwift

class UserObject: Object {
    
    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var image: Data?
//    @objc dynamic var family: [String]?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
