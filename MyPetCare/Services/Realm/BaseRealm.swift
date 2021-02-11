//
//  BaseRealm.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/11.
//

import Foundation
import RealmSwift

protocol BaseRealmProtocol:class {
    associatedtype Owned = Self where Owned:BaseRealmProtocol
    func write(_ block: (_ base: Owned) throws -> Void)
}

class BaseRealm : BaseRealmProtocol{
    
    var config:Realm.Configuration?
    private var realm:Realm!
    
    public func db()->Realm {
        return self.realm
    }

    public init(config:Realm.Configuration){
        self.config = config
        do{
            realm = try Realm(configuration: config)
            realm.autorefresh = true
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func getConfig()->Realm.Configuration?{
        return self.config
    }
    
    public func add (_ object:Object?){
        
        if let obj = object {
            autoreleasepool {
                try! realm.write {
                    realm.add(obj)
                }
            }
        }
    }
    
    public func set (_ object:Object?){
        
        if let obj = object {
            autoreleasepool {
                try! realm.write {
                    realm.add(obj , update: .all )
                }
            }
        }
    }
    
    public func set (_ objects:[Object]){
        
        autoreleasepool {
            try! realm.write {
                realm.add(objects , update: .all )
            }
        }
    }
    
    
    public func delete (_ object:Object?){
        
        if let obj = object {
            autoreleasepool {
                try! realm.write {
                    realm.delete(obj)
                }
            }
        }
    }
    
    public func delete (_ objects:[Object]?){
        
        if let objs = objects {
            autoreleasepool {
                try! realm.write {
                    realm.delete(objs)
                }
            }
        }
    }
    
    public func delete <Element: Object>(_ objects:Results<Element>?){
        
        if let objs = objects {
            autoreleasepool {
                try! realm.write {
                    realm.delete(objs)
                }
            }
        }
    }
    
    public func write(_ block: (() throws -> Void)) {
        autoreleasepool {
            try! realm.write {
                try block()
            }
        }
    }
    
    func write(_ block: (BaseRealm) throws -> Void) {
        autoreleasepool {
            try! realm.write {
                try block(self)
            }
        }
    }
}

