//
//  DatabaseService.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

import Foundation
import RealmSwift
import RxSwift

protocol DatabaseServiceType {
    func loadPetList() -> Results<PetObject>
    func add (_ object: Object?)
    func set (_ objects: [Object])
    
    func delete(_ Object: Object?)
    func delete(_ Object: [Object])
}

class DatabaseService: BaseService, DatabaseServiceType {
    
    let config = Realm.Configuration(deleteRealmIfMigrationNeeded: false)
    lazy var realm = try! Realm(configuration: config)
    
    public func db() -> Realm {
        
        return self.realm
    }
    
    func loadPetList() -> Results<PetObject> {
        return db().objects(PetObject.self)
    }
    
    func add (_ object:Object?) {
        
        if let obj = object {
            autoreleasepool {
                try! realm.write {
                    realm.add(obj)
                }
            }
        }
    }
    
    func set (_ object:Object?) {
        
        if let obj = object {
            autoreleasepool {
                try! realm.write {
                    realm.add(obj , update: .all )
                }
            }
        }
    }
    
    func set (_ objects:[Object]){
        
        autoreleasepool {
            try! realm.write {
                realm.add(objects , update: .all )
            }
        }
    }
    
    func delete(_ object: Object?) {
        
        if let obj = object {
            autoreleasepool {
                try! realm.write {
                    realm.delete(obj)
                }
            }
        }
    }
    
    func delete(_ objects: [Object]) {
        autoreleasepool {
            try! realm.write {
                realm.delete(objects)
            }
        }
    }
    
}
