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
    
    func add (_ object: Object?)
    
    func set (_ object: Object?)
    func set (_ objects: [Object]?)
    
    func delete(_ Object: Object?)
    func delete(_ Object: [Object]?)
    
    func update(_ objects: Object?)
    func update(_ objects: [Object]?)
    
    func write(_ block: (() throws -> Void))
    
    func loadPetList() -> Results<PetObject>
    
    func loadPetBRLog() -> Results<BRObject>
    func loadPetBRLog(_ petId: String) -> Results<BRObject>
    
    func loadLastData(_ petId: String) -> Results<LastMeasureObject>
    
    func laodBrCountDataHistory(_ petId: String) -> [BRObject]
    func loadPhysicsDataHistory(_ pedId: String) -> [PhysicsObject]
}

class DatabaseService: BaseService, DatabaseServiceType {
//    let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
//    var config = Realm.Configuration(deleteRealmIfMigrationNeeded: false)
    
    let config = Realm.Configuration(
        // 새로운 스키마 버전을 셋팅한다. 이 값은 이전에 사용했던 버전보다 반드시 커야한다.
        schemaVersion: Constants.DB_VERSION,
        migrationBlock: { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if (oldSchemaVersion < Constants.DB_VERSION) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        },
        deleteRealmIfMigrationNeeded: false
    )
    
    lazy var realm = try! Realm(configuration: config)
    
    func db() -> Realm {
        return self.realm
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
    
    func loadPetList() -> Results<PetObject> {
        return db().objects(PetObject.self).sorted(byKeyPath: "createDate")
    }
    
    func loadPetBRLog() -> Results<BRObject> {
        return db().objects(BRObject.self).sorted(byKeyPath: "createDate")
    }
    
    func loadPetBRLog(_ petId: String) -> Results<BRObject> {
        let predicate = NSPredicate(format: "petId = %@", petId)
        return db().objects(BRObject.self).filter(predicate).sorted(byKeyPath: "createDate")
    }
    
    func loadLastData(_ petId: String) -> Results<LastMeasureObject> {
        let predicate = NSPredicate(format: "petId = %@", petId)
        return db().objects(LastMeasureObject.self).filter(predicate)
    }
    
    func laodBrCountDataHistory(_ petId: String) -> [BRObject] {
        let predicate = NSPredicate(format: "petId = %@", petId)
        return db().objects(BRObject.self)
            .filter(predicate)
            .toArray()
            .sorted(by: {$0.createDate ?? Date() > $1.createDate ?? Date()})
    }
    
    func loadPhysicsDataHistory(_ petId: String) -> [PhysicsObject] {
        let predicate = NSPredicate(format: "petId = %@", petId)
        return db().objects(PhysicsObject.self)
            .filter(predicate)
            .toArray()
            .sorted(by: {$0.createDate ?? Date() > $1.createDate ?? Date()})
    }
}
