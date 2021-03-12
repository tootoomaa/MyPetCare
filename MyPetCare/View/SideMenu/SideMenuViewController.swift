//
//  SideMenuViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/03/12.
//

import Foundation
import UIKit
import ReactorKit
import RxSwift

class SideMenuViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    let mainView = SideMenuView()
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    private func configureTableView() {
        
        
    }
    
    func bind(reactor: SideMenuViewReactor) {
        
    }
    
}
