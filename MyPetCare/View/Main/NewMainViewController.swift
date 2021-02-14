//
//  NewMainViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/14.
//

import Foundation
import UIKit

class NewMainViewController: UIViewController {
    
    let mainView = NewMainView()
    
    
    // MARK: - Life cycle
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
