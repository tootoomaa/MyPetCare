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
    var realm: Realm { get }
    
    func db() -> Realm
    
    func loadPetList() -> Results<PetObject>
    
    func add (_ object: Object?)
    
    func set (_ object: Object?)
    func set (_ objects: [Object]?)
    
    func delete(_ Object: Object?)
    func delete(_ Object: [Object]?)
    
    func update(_ objects: Object?)
    func update(_ objects: [Object]?)
    
    func write(_ block: (() throws -> Void))
}

class DatabaseService: BaseService, DatabaseServiceType {
    
//    let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    var config = Realm.Configuration(deleteRealmIfMigrationNeeded: false)
    lazy var realm = try! Realm(configuration: config)
    
    
    
    func db() -> Realm {
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
    
    func set (_ objects:[Object]?){
        if let obj = objects {
            autoreleasepool {
                try! realm.write {
                    realm.add(obj, update: .all )
                }
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
    
    func delete(_ objects: [Object]?) {
        if let obj = objects {
            autoreleasepool {
                try! realm.write {
                    realm.delete(obj)
                }
            }
        }
    }
    
    func update(_ objects: [Object]?) {
        if let obj = objects {
            autoreleasepool {
                try! realm.write {
                    realm.add(obj, update: .modified)
                }
            }
        }
    }
    
    func update(_ objects: Object?) {
        if let obj = objects {
            autoreleasepool {
                try! realm.write {
                    realm.add(obj, update: .modified)
                }
            }
        }
    }
    
    func write(_ block: (() throws -> Void)) {
        autoreleasepool {
            try! realm.write {
                try block()
            }
        }
    }
}
