//
//  BaseService.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/06.
//

class BaseService {
  unowned let provider: ServiceProviderType

  init(provider: ServiceProviderType) {
    self.provider = provider
  }
}
