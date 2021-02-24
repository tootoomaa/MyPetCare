//
//  MeasureDetailViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/24.
//

import Foundation
import ReactorKit

class MeasureDetailViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    var mainFrameMenuType: MainFrameMenuType
    
    let tableView = UITableView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - Life cycle
    init(type: MainFrameMenuType) {
        self.mainFrameMenuType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(mainFrameMenuType.rawValue) 측정 이력"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: - Reactor Binding
    func bind(reactor: MeasureViewReactor) {
        
        if mainFrameMenuType == .breathRate {
            self.rx.viewDidLoad
                .map{Reactor.Action.loadBrCountData}
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            reactor.state.map{$0.brCountHistory}
                .distinctUntilChanged()
                .compactMap{$0}
                .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { raw, data, cell in
                    
                    cell.textLabel?.text = "\(data.resultBR)"
                    
                }.disposed(by: disposeBag)
            
        } else if mainFrameMenuType == .physics {
            
            self.rx.viewDidLoad
                .map{Reactor.Action.loadPhysicsData}
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
                
            reactor.state.map{$0.physicsHistory}
                .distinctUntilChanged()
                .compactMap{$0}
                .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { raw, data, cell in
                    
                    cell.textLabel?.text = "\(data.height)"
                    
                }.disposed(by: disposeBag)
            
        }
        

    }
}
