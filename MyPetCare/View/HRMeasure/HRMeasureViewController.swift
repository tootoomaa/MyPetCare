//
//  BPMeasureViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/13.
//

import Foundation
import ReactorKit
import UIKit

class HRMeasureViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    
    
    // MARK: - LifeCycle
    override func loadView() {
        view = HReasureView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.mainColor
        
        configureNavigation()
    }
    
    private func configureNavigation() {
        self.navigationItem.title = "혈압 측정"
        self.navigationController?.configureNavigationBarAppearance(.white)
        
        let closeNanviButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        closeNanviButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        self.navigationItem.leftBarButtonItem = closeNanviButton
    }
    
    // MARK: - Reactor Binding
    func bind(reactor: BPMeasureViewReactor) {
        
    }
    
}
