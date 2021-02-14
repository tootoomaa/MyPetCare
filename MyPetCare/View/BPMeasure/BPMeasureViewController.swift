//
//  BPMeasureViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import ReactorKit
import UIKit

class BPMeasureViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - LifeCycle
    override func loadView() {
        view = BPMeasureView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureNavigation()
    }
    
    private func configureNavigation() {
        self.navigationItem.title = "혈압 측정"
        self.navigationController?.configureNavigationBarAppearance(.white)
    }
    
    func bind(reactor: BPMeasureViewReactor) {
        
    }
    
}
