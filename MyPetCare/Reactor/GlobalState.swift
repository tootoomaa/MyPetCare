//
//  GlobalState.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/22.
//

import Foundation
import RxSwift
import RxCocoa

class GlobalState {
    
    static let lastDateUpdate = PublishSubject<Void>()
    
    static let MeasureDataUpdateAndChartReload = PublishSubject<Void>()
    
    static let petDeleted = PublishSubject<Void>()
}
