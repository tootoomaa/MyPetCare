//
//  MeasureDetailViewController.swift
//  MyPetCare
//
//  Created by 김광수 on 2021/02/24.
//

import Foundation
import ReactorKit

class MeasureDetailViewController: UIViewController, View {
    
    let padding: CGFloat = 8
    
    // MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    
    var mainFrameMenuType: MainFrameMenuType
    
    var navigationImageView: UIImageView?
    
    let tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.register(MeasureDetailTableViewCell.self,
                    forCellReuseIdentifier: MeasureDetailTableViewCell.identifier)
        $0.rowHeight = 130
        $0.separatorStyle = .none
        $0.allowsMultipleSelectionDuringEditing = true
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
        
        view.backgroundColor = .white
        
        configureNavigationController()
        
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 네비게이션 바 Pet Profile Image Appear
        let imageView = UIImageView().then {
            $0.image = UIImage(data: reactor?.selectedPet.image ?? UIImage().pngData()!)
            $0.contentMode = .scaleAspectFit
            $0.addCornerRadius(20)
            $0.alpha = 0
        }
        navigationImageView = imageView
        
        self.navigationController?.navigationBar.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        UIView.animate(withDuration: 0.5) {
            imageView.alpha = 1
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationImageView?.alpha = 0
    }
    
    private func configureNavigationController() {
        navigationItem.title = "\(mainFrameMenuType.rawValue) 측정 이력"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.configureNavigationBarAppearance(.white)
    }
    
    private func configureLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(padding*2)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(padding*2)
            $0.bottom.equalToSuperview()
        }
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
                .bind(to: tableView.rx.items(cellIdentifier: MeasureDetailTableViewCell.identifier,
                                             cellType: MeasureDetailTableViewCell.self)) { raw, data, cell in
                    
                    cell.configureLaytoutWithBRObject(data: data)
                    
                }.disposed(by: disposeBag)
            
        } else if mainFrameMenuType == .physics {
            
            self.rx.viewDidLoad
                .map{Reactor.Action.loadPhysicsData}
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
                
            reactor.state.map{$0.physicsHistory}
                .distinctUntilChanged()
                .compactMap{$0}
                .bind(to: tableView.rx.items(cellIdentifier: MeasureDetailTableViewCell.identifier,
                                             cellType: MeasureDetailTableViewCell.self)) { raw, data, cell in
                    
                    cell.configureLaytoutWithPhysicsObject(data: data)
                    
                }.disposed(by: disposeBag)
        }
    }
}
