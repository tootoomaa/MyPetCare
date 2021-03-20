//
//  ServiceProvider.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

import Foundation

protocol ServiceProviderType: class {
    var dataBaseService: DatabaseServiceType { get }
}

class ServiceProvider: ServiceProviderType {
    lazy var dataBaseService: DatabaseServiceType = DatabaseService(provider: self)
}
