//
//  Results+Extension.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/09.
//

import Foundation
import RealmSwift

extension Results {
    
    public func toArray() -> [Element] {
        return Array(self)
    }
}
