//
//  DefaultRealm.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/11.
//

import Foundation
import RealmSwift

final class SharedDB:BaseRealm  {

    /// singleton instance
    static let shared : SharedDB = {
        
        let instance = SharedDB()
        
        return instance
    }()
    
    private init() {
        
        let config = Realm.Configuration(
            deleteRealmIfMigrationNeeded: true
        )
        
        super.init(config: config)
    }
}
