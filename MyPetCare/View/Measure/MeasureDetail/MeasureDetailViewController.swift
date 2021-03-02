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
    
    let alertLabel = UILabel().then {
        $0.text = "삭제되었습니다."
        $0.font = .systemFont(ofSize: 15, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = .white
        $0.backgroundColor = .black
        $0.alpha = 0.8
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .white
        $0.register(MeasureDetailTableViewCell.self,
                    forCellReuseIdentifier: MeasureDetailTableViewCell.identifier)
        $0.rowHeight = 70
        $0.separatorStyle = .none
        $0.delegate = self
    }
    
    var emptyImageView = UIImageView().then {
        let emptyImage = UIImage(systemName: "tray.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.black)
        $0.image = emptyImage
        $0.contentMode = .scaleAspectFit
    }
    
    var emptyLabel = UILabel().then {
        $0.text = "측정 이력이 비었습니다."
        $0.font = .dynamicFont(name: "Cafe24Syongsyong", size: 15)
        $0.textColor = .black
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
            $0.addCornerRadius(18)
            $0.alpha = 0
        }
        navigationImageView = imageView
        
        self.navigationController?.navigationBar.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(2)
            $0.width.height.equalTo(36)
        }
        
        UIView.animate(withDuration: 0.3) {
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
        [tableView, emptyImageView, emptyLabel, alertLabel].forEach {
            view.addSubview($0)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(padding*2)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(padding*2)
            $0.bottom.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(100)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(8)
            $0.centerX.equalTo(emptyImageView)
        }
        
        alertLabel.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.width.equalTo(200)
            $0.height.equalTo(40)
        }
    }
    
    // MARK: - Reactor Binding
    func bind(reactor: MeasureViewReactor) {
        
        if mainFrameMenuType == .breathRateSV {
            self.rx.viewDidLoad
                .map{Reactor.Action.loadBrCountData}
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            reactor.state.map{$0.brCountHistory}
                .distinctUntilChanged()
                .do(onNext: { [unowned self] in
                    self.emptyLabel.isHidden = !$0.isEmpty
                    self.emptyImageView.isHidden = !$0.isEmpty
                    self.tableView.isScrollEnabled = !$0.isEmpty
                })
                .compactMap{$0}
                .bind(to: tableView.rx.items(cellIdentifier: MeasureDetailTableViewCell.identifier,
                                             cellType: MeasureDetailTableViewCell.self)) { raw, data, cell in
                    
                    cell.configureLaytoutWithBRObject(data: data)
                    
                }.disposed(by: disposeBag)
            
        } else if mainFrameMenuType == .physicsSV {
            
            self.rx.viewDidLoad
                .map{Reactor.Action.loadPhysicsData}
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
                
            reactor.state.map{$0.physicsHistory}
                .distinctUntilChanged()
                .do(onNext: { [unowned self] in
                    self.emptyLabel.isHidden = !$0.isEmpty
                    self.emptyImageView.isHidden = !$0.isEmpty
                    self.tableView.isScrollEnabled = !$0.isEmpty
                })
                .compactMap{$0}
                .bind(to: tableView.rx.items(cellIdentifier: MeasureDetailTableViewCell.identifier,
                                             cellType: MeasureDetailTableViewCell.self)) { raw, data, cell in
                    
                    cell.configureLaytoutWithPhysicsObject(data: data)
                    
                }.disposed(by: disposeBag)
        }
    }
}

//MARK: - UITableViewDelegate
extension MeasureDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "삭제") {
            [unowned self] (action, sourceView, actionPerformed) in
            
            guard let reactor = reactor else { return }
            Observable<Int>.just(indexPath.row)
                .map{Reactor.Action.removeMeasureData($0, mainFrameMenuType)}
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            self.alertViewAnimaion("삭제 되었습니다.")
            
            actionPerformed(true)
        }
        
        deleteAction.backgroundColor = .red
        
        let configure = UISwipeActionsConfiguration(actions: [deleteAction])
        configure.performsFirstActionWithFullSwipe = false
        
        return configure
    }
}

//MARK: - AlerView Animation
extension MeasureDetailViewController {
    
    func alertViewAnimaion(_ text: String) {
        
        self.alertLabel.text = text
        self.alertLabel.alpha = 0.8
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            UIView.animateKeyframes(withDuration: 2, delay: 0) {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                    self.alertLabel.isHidden = false
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1.5) {
                    self.alertLabel.alpha = 0
                }
                
            }
        }
    }
    
}
